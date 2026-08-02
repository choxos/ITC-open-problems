#!/bin/bash
# Run until all 224 cells exist, restarting after each death.
#
# WHY. This machine is shared and heavily oversubscribed: swap runs near its
# limit, and macOS kills R processes with SIGKILL under memory pressure with
# nothing in their logs. A sibling study lost four runners in an hour that way.
# The runner checkpoints every 250 replicates and resumes by file existence, so
# invoking it repeatedly is idempotent and a death costs at most one chunk.
#
# LIVENESS: PIDFILE, THEN ADOPTION, THEN LAUNCH. The supervisor and the runner die
# independently. A fresh supervisor that assumes no runner exists will start a
# second one, and two runners scanning the same list of missing cells duplicate
# every fit and race on writes; that happened in a sibling study and halved its
# throughput. So the pidfile is authoritative when it names a live process, an
# existing runner is adopted when it does not, and only then is one launched.
# The search matches nothing but this study's runner because it keys on the
# script path.
#
# ORDERING LIVES IN THE RUNNER, NOT HERE. `build_grid()` puts the registered
# primary cells first and the falsifier's cells second, so the supervisor needs
# no knowledge of which cells matter and cannot drift from section 7 when the
# design changes.
#
#   nohup bash run-supervised.sh >> logs/supervisor.log 2>&1 &
cd "$(dirname "$0")" || exit 1
mkdir -p logs
PIDFILE=logs/runner.pid
i=0
while true; do
  n=$(ls results/run/*.rds 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" -ge 224 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') COMPLETE at $n/224 cells after $i restarts"
    rm -f "$PIDFILE"; exit 0
  fi
  alive=0
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    alive=1
  else
    # ADOPTION MUST CHECK IDENTITY, NOT JUST THE SCRIPT NAME. `R/04-run.R` is a
    # relative path and this machine hosts other repositories whose runners have
    # the same file name; on the first attempt this loop adopted a nine-hour-old
    # process belonging to a different project and would never have started
    # anything. The candidate's working directory has to be THIS study's.
    here=$(pwd -P)
    matches=""
    for m in $(pgrep -f "[-]-file=R/04-run.R"); do
      c=$(lsof -p "$m" -a -d cwd -Fn 2>/dev/null | grep '^n' | cut -c2-)
      [ "$c" = "$here" ] && matches="$matches $m"
    done
    matches="$matches "
    found=""
    for m in $matches; do
      mp=$(ps -o ppid= -p "$m" 2>/dev/null | tr -d ' ')
      case " $matches " in *" $mp "*) ;; *) found=$m; break ;; esac
    done
    if [ -n "$found" ]; then
      echo "$(date '+%Y-%m-%d %H:%M') adopting existing runner $found at $n/224"
      echo "$found" > "$PIDFILE"; alive=1
    fi
  fi
  if [ "$alive" -eq 0 ]; then
    i=$((i+1))
    echo "$(date '+%Y-%m-%d %H:%M') restart #$i at $n/224 cells"
    nohup Rscript R/04-run.R >> logs/run.log 2>&1 &
    echo $! > "$PIDFILE"
    sleep 30
  fi
  sleep 60
done
