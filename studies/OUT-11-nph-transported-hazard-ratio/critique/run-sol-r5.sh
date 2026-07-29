#!/bin/zsh
cd "$(dirname "$0")/.."
P="$(cat critique/prompt.txt)
$(cat critique/design-for-critique-r5.md)"
codex exec -m gpt-5.6-sol -c model_reasoning_effort=max -s read-only \
  --skip-git-repo-check --ignore-rules "$P" > critique/sol-critique-r5.txt 2> critique/sol-critique-r5.err < /dev/null
echo "sol done exit=$? bytes=$(wc -c < critique/sol-critique-r5.txt)"
