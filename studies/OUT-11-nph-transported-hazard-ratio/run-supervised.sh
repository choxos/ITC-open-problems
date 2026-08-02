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
# LIVENESS IS TRACKED BY PIDFILE, NOT BY pgrep. The previous version matched on a
# command-line pattern, which is fragile in both directions: it can match the
# supervisor's own subshell and refuse to launch anything, and it silently does
# nothing once the pattern drifts. A pidfile holding the child this supervisor
# started, tested with `kill -0`, answers the only question that matters, which is
# whether the runner THIS loop launched is still alive. The runner skips any
# replicate whose file already exists, so even a spurious extra launch would waste
# work rather than corrupt the store.
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
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then alive=1; fi
  if [ "$alive" -eq 0 ]; then
    i=$((i+1))
    echo "$(date '+%Y-%m-%d %H:%M') restart #$i at $n/840"
    PASS=mlnmr WORKERS=1 nohup Rscript R/07-run.R >> logs/e3-supervised.log 2>&1 &
    echo $! > "$PIDFILE"
    sleep 120
  fi
  sleep 60
done
