#!/usr/bin/env bash
# Roll the LIVE deck back to a saved version, so editing resumes from that state.
#   rollback.sh v3.1
set -uo pipefail
REPO="/Users/jarredwinn/Projects/anchorage-agentic-preview"
cd "$REPO" || exit 1
VER="${1:?usage: rollback.sh vMAJOR.MINOR (e.g. v3.1)}"
SRC="versions/$VER.html"
DECK="anchorage-agentic-launch-sprint.html"
[ -f "$SRC" ] || { echo "no such version: $VER (see versions/)"; exit 1; }
cp "$SRC" "$DECK"
git add "$DECK" >/dev/null 2>&1
git commit -q -m "rollback live deck to $VER" >/dev/null 2>&1
git push -q >/dev/null 2>&1 || { git pull --rebase -q >/dev/null 2>&1; git push -q >/dev/null 2>&1; }
echo "live deck rolled back to $VER; next edit will snapshot forward from here"
