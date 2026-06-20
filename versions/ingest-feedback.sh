#!/usr/bin/env bash
# Read Marker.io feedback for the Anchorage sprint deck, compactly, so it can be
# actioned (keep / discard / edit) and closed back through the loop.
#
#   ingest-feedback.sh            -> list OPEN feedback items
#   ingest-feedback.sh <number>   -> full body of one item (annotation text, URL,
#                                    screenshot, element, reporter, browser/OS)
#   ingest-feedback.sh --all      -> list every item incl. closed
#
# Loop: annotate in Marker -> Marker files a private GitHub issue here ->
# apply the edit to the deck -> commit (auto-snapshots vX.Y) ->
# close the issue with the version link (2-way syncs the Marker item to Done).
set -uo pipefail
REPO="Winnsolutionsadmin/anchorage-deck-feedback"

if [ "${1:-}" = "--all" ]; then STATE=all; shift; else STATE=open; fi

if [ -n "${1:-}" ]; then
  gh issue view "$1" -R "$REPO" \
    --json number,title,state,body,url,labels,createdAt,author \
    --jq '"#\(.number) [\(.state)]  \(.title)\nby \(.author.login // "marker")  ·  \(.createdAt[0:16])\n\(.url)\nlabels: \([.labels[].name]|join(", "))\n\n\(.body)"' 2>&1
  exit 0
fi

echo "Marker feedback ($STATE) in $REPO:"
out=$(gh issue list -R "$REPO" --state "$STATE" -L 50 \
  --json number,title,createdAt,labels \
  --jq '.[] | "  #\(.number)  \(.createdAt[0:10])  [\([.labels[].name]|join(","))]  \(.title)"' 2>&1)
if [ -z "$out" ]; then echo "  (none yet — file a test annotation in Marker to prove the pipe)"; else echo "$out"; fi
echo
echo "Detail:  versions/ingest-feedback.sh <number>"
echo "Applied: gh issue close <n> -R $REPO -c \"applied in vX.Y — <version link>\""
