#!/usr/bin/env bash
# Auto-version the Anchorage sprint deck. Safe to run every turn (Stop hook):
# it no-ops when the deck is unchanged since the last snapshot.
#   snapshot.sh "description"   -> snapshot current deck if changed + regen index + push
#   snapshot.sh --reindex       -> just regenerate the index from the manifest
set -uo pipefail
REPO="/Users/jarredwinn/Projects/anchorage-agentic-preview"
DECK="anchorage-agentic-launch-sprint.html"
VDIR="versions"
cd "$REPO" || exit 0
mkdir -p "$VDIR"
MAN="$VDIR/manifest.tsv"; touch "$MAN"

gen_index(){
  local rows="" ver iso commit desc
  while IFS=$'\t' read -r ver iso commit desc; do
    [ -z "$ver" ] && continue
    rows="<tr><td class=v>$ver</td><td class=t>$iso</td><td>$desc</td><td><a href=\"./$ver.html\" target=_blank>View</a></td><td class=c>$commit</td></tr>$rows"
  done < "$MAN"
  cat > "$VDIR/index.html" <<HTML
<!doctype html><html lang=en><head><meta charset=utf-8>
<meta name=robots content="noindex,nofollow,noarchive,nosnippet">
<meta name=viewport content="width=device-width,initial-scale=1">
<title>Anchorage Sprint Deck — Version History</title>
<style>
:root{--navy:#08111f;--panel:#10213a;--brass:#cda349;--ink:#eaf0f8;--muted:#8ba0bd;--line:rgba(159,184,219,.13)}
*{box-sizing:border-box}body{margin:0;background:var(--navy);color:var(--ink);font:15px/1.55 'Hanken Grotesk',system-ui,sans-serif;padding:40px}
h1{font-family:Fraunces,Georgia,serif;color:var(--brass);font-weight:600;margin:0 0 6px}
p.sub{color:var(--muted);max-width:680px;margin:0}
table{border-collapse:collapse;width:100%;margin-top:26px;font-size:14px}
th,td{text-align:left;padding:10px 14px;border-bottom:1px solid var(--line);vertical-align:top}
th{color:var(--brass);font:12px/1 'IBM Plex Mono',monospace;text-transform:uppercase;letter-spacing:.05em}
td.v{font-weight:700;color:var(--brass);white-space:nowrap} td.t,td.c{font-family:'IBM Plex Mono',monospace;color:var(--muted);font-size:12px;white-space:nowrap}
a{color:var(--brass);font-weight:600} tr:hover td{background:var(--panel)}
.roll{margin-top:22px;color:var(--muted);font-size:13px;border-left:2px solid var(--brass);padding-left:12px;max-width:680px}
.roll code{color:var(--ink)}
</style></head><body>
<h1>Anchorage Sprint Deck &mdash; Version History</h1>
<p class=sub>Every editing turn auto-snapshots a new version. Click <b>View</b> to open that exact version. To resume editing from one, tell Kai &ldquo;roll back to vX.Y&rdquo; and that snapshot becomes the live deck.</p>
<table><thead><tr><th>Version</th><th>Time (UTC)</th><th>Change</th><th>View</th><th>Commit</th></tr></thead>
<tbody>
$rows
</tbody></table>
<p class=roll>Current live deck: <a href="../anchorage-agentic-launch-sprint.html" target=_blank>anchorage-agentic-launch-sprint.html</a> &nbsp;&middot;&nbsp; rollback: <code>versions/rollback.sh vX.Y</code></p>
</body></html>
HTML
}

if [ "${1:-}" = "--reindex" ]; then gen_index; exit 0; fi

DESC="${1:-edit}"
MAJOR=$(cat "$VDIR/.major" 2>/dev/null || echo 3)
LAST=$(ls "$VDIR"/v${MAJOR}.*.html 2>/dev/null | sed -E "s#.*/v${MAJOR}\.([0-9]+)\.html#\1#" | sort -n | tail -1)
MINOR=$(( ${LAST:--1} + 1 ))
VER="v${MAJOR}.${MINOR}"
NEWEST=$(ls -t "$VDIR"/v*.html 2>/dev/null | head -1)
if [ -n "$NEWEST" ] && cmp -s "$DECK" "$NEWEST"; then exit 0; fi   # unchanged -> no snapshot
cp "$DECK" "$VDIR/$VER.html"
printf '%s\t%s\t%s\t%s\n' "$VER" "$(date -u +%Y-%m-%dT%H:%MZ)" "$(git rev-parse --short HEAD 2>/dev/null)" "$DESC" >> "$MAN"
gen_index
git add "$VDIR" >/dev/null 2>&1
git commit -q -m "snapshot $VER: $DESC" >/dev/null 2>&1
git push -q >/dev/null 2>&1 || { git pull --rebase -q >/dev/null 2>&1; git push -q >/dev/null 2>&1; }
echo "$VER"
