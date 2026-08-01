#!/bin/bash
# Run until all 48 cells exist, restarting after each death.
#
# WHY. This machine is shared with another project's compute and R processes here
# are killed mid-cell with no error in their logs. The runner checkpoints every
# 250 replicates and resumes by file existence, so invoking it repeatedly is
# idempotent: a death costs at most one chunk, and the loop needs no process
# detection to be correct. Primary-outcome cells run first so the headline is
# answerable before the controls finish.
#
#   nohup bash run-supervised.sh >> logs/supervisor.log 2>&1 &
cd "$(dirname "$0")" || exit 1
mkdir -p logs
PRIMARY=5,6,11,12,17,18,23,24,29,30,35,36,41,42,47,48
for i in $(seq 1 400); do
  n=$(ls results/run/*.rds 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" -ge 48 ]; then
    echo "$(date '+%Y-%m-%d %H:%M') COMPLETE at $n/48 cells after $((i-1)) passes"; exit 0
  fi
  echo "$(date '+%Y-%m-%d %H:%M') pass $i, $n/48 cells done"
  CELLS=$PRIMARY Rscript R/03-run.R >> logs/run.log 2>&1
  Rscript R/03-run.R >> logs/run.log 2>&1
  sleep 5
done
