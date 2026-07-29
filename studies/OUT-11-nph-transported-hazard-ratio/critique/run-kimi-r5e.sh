#!/bin/zsh
cd "$(dirname "$0")/.."
P="$(cat critique/prompt.txt)

IMPORTANT: You have no tools available. Do not attempt to read files, run commands, list directories, or spawn agents. Answer entirely from the text below and your own knowledge of this literature. Reply with JSON only.

$(cat critique/design-for-critique-r5-e.md)"
opencode run --pure -m opencode-go/kimi-k3 "$P" > critique/kimi-critique-r5e.txt 2> critique/kimi-critique-r5e.err < /dev/null
echo "kimi e done exit=$? bytes=$(wc -c < critique/kimi-critique-r5e.txt)"
