#!/bin/bash
# Keep the ML-NMR pass alive until it completes.
#
# WHY THIS EXISTS. This run has died three times mid-replicate with no error in
# its log and no clear cause: once to a fork deadlock in mclapply, once under
# heavy machine contention, once while another study was running. Each death cost
# hours before anyone noticed, and the pass is a multi-day job whose store is
# checkpointed per replicate, so a restart loses at most one replicate.
#
# The supervisor does not diagnose the deaths. It removes their cost, which is
# the part that was actually hurting: progress now survives whatever is killing
# the process. It exits on completion and reports every restart it performs, so
# a death rate that is climbing stays visible rather than being papered over.
#
#   nohup bash run-supervised.sh >> logs/supervisor.log 2>&1 &
cd "$(dirname "$0")" || exit 1
i=0
while true; do
  n=$(ls results/cells/mlnmr-*.rds 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" -ge 840 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') COMPLETE at $n/840 after $i restarts"; exit 0
  fi
  if ! pgrep -f "R/07-run" >/dev/null; then
    i=$((i+1))
    echo "$(date '+%Y-%m-%d %H:%M') restart #$i at $n/840"
    PASS=mlnmr WORKERS=1 nohup Rscript R/07-run.R >> logs/e3-supervised.log 2>&1 &
    sleep 120
  fi
  sleep 60
done
