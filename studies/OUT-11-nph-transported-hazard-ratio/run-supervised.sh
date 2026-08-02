#!/bin/bash
# Keep the ML-NMR pass alive until it completes.
#
# WHY THIS EXISTS. This run has died four times mid-replicate with no error in its
# log and no clear cause: once to a fork deadlock in mclapply, twice under heavy
# machine contention from another project's compute, and once taking the previous
# supervisor down with it. Each death cost hours before anyone noticed, and the
# pass is a multi-day job whose store is checkpointed per replicate, so a restart
# loses at most one replicate.
#
# The supervisor does not diagnose the deaths. It removes their cost, which is the
# part that was actually hurting: progress now survives whatever is killing the
# process. It exits on completion and reports every restart it performs, so a
# death rate that is climbing stays visible rather than being papered over.
#
# LIVENESS: PIDFILE FIRST, THEN ADOPTION, THEN LAUNCH. The supervisor and the
# runner die independently, and the case that actually cost time was the
# supervisor dying while its runner kept working: a fresh supervisor with no
# memory of that runner launches a second one, both scan the same list of missing
# replicates, and they duplicate work and race on writes. That happened once here,
# and the two competing runs halved each other's throughput before the duplicate
# was found and killed.
#
# So the check has three steps. The pidfile is authoritative when it names a live
# process, because it identifies the specific child this loop started. When it does
# not, the loop looks for an existing runner before launching, and adopts it. Only
# when both fail does it start anything. A false negative in the adoption search
# costs a duplicate; a false positive costs one cycle of waiting, then a re-check.
#
# The runner skips any replicate whose file already exists, so a duplicate wastes
# work rather than corrupting the store, but wasted work on a multi-day job is the
# thing this script exists to prevent.
#
#   nohup bash run-supervised.sh >> logs/supervisor.log 2>&1 &
cd "$(dirname "$0")" || exit 1
mkdir -p logs
PIDFILE=logs/mlnmr-runner.pid
i=0
while true; do
  n=$(ls results/cells/mlnmr-*.rds 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" -ge 840 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') COMPLETE at $n/840 after $i restarts"
    rm -f "$PIDFILE"; exit 0
  fi
  alive=0
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    alive=1
  else
    # No pidfile, or it names a dead process. Adopt a runner already working
    # rather than starting a rival to it. The runner forks one child per chain
    # and the children inherit its command line, so the search matches all of
    # them; keep only the one whose parent is not itself a match, which is the
    # runner rather than a chain. Tracking a chain would relaunch spuriously the
    # moment that chain finished.
    # Space-separated, so the membership test below cannot depend on pgrep's
    # output order: with newlines still in it, `case " $matches "` would only
    # ever match the first pid.
    matches=$(pgrep -f "[-]-file=R/07-run.R" | tr '\n' ' ')
    found=""
    for m in $matches; do
      mp=$(ps -o ppid= -p "$m" 2>/dev/null | tr -d ' ')
      case " $matches " in *" $mp "*) ;; *) found=$m; break ;; esac
    done
    if [ -n "$found" ]; then
      echo "$(date '+%Y-%m-%d %H:%M') adopting existing runner $found at $n/840"
      echo "$found" > "$PIDFILE"; alive=1
    fi
  fi
  if [ "$alive" -eq 0 ]; then
    i=$((i+1))
    echo "$(date '+%Y-%m-%d %H:%M') restart #$i at $n/840"
    PASS=mlnmr WORKERS=1 nohup Rscript R/07-run.R >> logs/e3-supervised.log 2>&1 &
    echo $! > "$PIDFILE"
    sleep 120
  fi
  sleep 60
done
