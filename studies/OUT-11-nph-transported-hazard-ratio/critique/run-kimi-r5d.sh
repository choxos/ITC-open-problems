#!/bin/zsh
cd "$(dirname "$0")/.."
P="$(cat critique/prompt.txt)

IMPORTANT: You have no tools available. Do not attempt to read files, run commands, list directories, or spawn agents. Answer entirely from the text below and your own knowledge of this literature. Reply with JSON only.

$(cat critique/design-for-critique-r5-d.md)"
opencode run --pure -m opencode-go/kimi-k3 "$P" > critique/kimi-critique-r5d.txt 2> critique/kimi-critique-r5d.err < /dev/null
echo "kimi d done exit=$? bytes=$(wc -c < critique/kimi-critique-r5d.txt)"
