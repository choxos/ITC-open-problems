#!/bin/zsh
cd /Users/choxos/Documents/GitHub/ITC-open-problems/studies/IDN-05-shared-modifier-check-power
while pgrep -f "04-run.R" > /dev/null; do sleep 30; done
echo "=== main run finished, starting boundary arm ===" 
Rscript R/04b-run-boundary.R 3 >> logs/run.log 2>> logs/run.err
echo "=== boundary arm finished, starting integration check ==="
Rscript R/07-integration-check.R 12 >> logs/run.log 2>> logs/run.err
echo "=== ALL RUNS COMPLETE ==="
