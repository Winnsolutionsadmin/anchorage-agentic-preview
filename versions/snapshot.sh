#!/usr/bin/env bash
# Auto-version the Anchorage sprint deck. Safe to run on every commit:
# no-ops when the deck is unchanged since the last snapshot.
#   snapshot.sh "description"   -> snapshot current deck if changed + regen index + push
#   snapshot.sh --reindex       -> just regenerate the index from the manifest
# Per-version prompt: if versions/.prompt is non-empty it is saved as the prompt
# that produced this version (shown + editable + resendable in the browser).
set -uo pipefail
REPO="/Users/jarredwinn/Projects/anchorage-agentic-preview"
DECK="anchorage-agentic-launch-sprint.html"
VDIR="versions"
cd "$REPO" || exit 0
mkdir -p "$VDIR" "$VDIR/prompts"
MAN="$VDIR/manifest.tsv"; touch "$MAN"

gen_index(){
  local rows="" ver iso commit desc prev="" hasP parent
  while IFS=$'\t' read -r ver iso commit desc; do
    [ -z "$ver" ] && continue
    parent="$prev"
    hasP="no"; [ -s "$VDIR/prompts/$ver.txt" ] && hasP="yes"
    rows="<tr class=vrow><td class=v>$ver</td><td class=t>$iso</td><td>$desc</td><td><a href=\"./$ver.html\" target=_blank>View</a></td><td><button class=pbtn onclick=\"tp('$ver')\">Prompt &amp; resend</button></td><td class=c>$commit</td></tr><tr class=prow id=prow-$ver style=display:none><td colspan=6><div class=plabel>Prompt that produced <b>$ver</b> &middot; applied to <b>${parent:-base}</b>. Edit it and resend to branch a new version from <b>${parent:-base}</b>:</div><textarea id=pta-$ver class=pta data-has=$hasP placeholder=\"(no prompt recorded for this version)\"></textarea><div class=pacts><button class=rbtn onclick=\"rs('$ver','${parent:-}')\">Copy resend command</button> <span id=msg-$ver class=pmsg></span></div></td></tr>$rows"
    prev="$ver"
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
p.sub{color:var(--muted);max-width:720px;margin:0}
table{border-collapse:collapse;width:100%;margin-top:26px;font-size:14px}
th,td{text-align:left;padding:10px 14px;border-bottom:1px solid var(--line);vertical-align:top}
th{color:var(--brass);font:12px/1 'IBM Plex Mono',monospace;text-transform:uppercase;letter-spacing:.05em}
td.v{font-weight:700;color:var(--brass);white-space:nowrap} td.t,td.c{font-family:'IBM Plex Mono',monospace;color:var(--muted);font-size:12px;white-space:nowrap}
a{color:var(--brass);font-weight:600} tr.vrow:hover td{background:var(--panel)}
button{font:inherit;font-size:12px;cursor:pointer;background:transparent;color:var(--brass);border:1px solid var(--brass);border-radius:6px;padding:4px 10px}
button:hover{background:var(--brass);color:var(--navy)}
.prow td{background:rgba(8,17,31,.6)}
.plabel{color:var(--muted);font-size:13px;margin-bottom:8px}
.pta{width:100%;min-height:120px;background:#0b1626;color:var(--ink);border:1px solid var(--line);border-radius:8px;padding:12px;font:13px/1.5 'IBM Plex Mono',monospace;resize:vertical}
.pacts{margin-top:8px;display:flex;align-items:center;gap:12px}
.rbtn{border-color:var(--brass2,#e3c578)}
.pmsg{color:var(--brass);font-size:12px}
.roll{margin-top:22px;color:var(--muted);font-size:13px;border-left:2px solid var(--brass);padding-left:12px;max-width:720px}
.roll code{color:var(--ink)}
</style></head><body>
<h1>Anchorage Sprint Deck &mdash; Version History</h1>
<p class=sub>Every editing turn auto-snapshots a version. <b>View</b> opens that exact build. <b>Prompt &amp; resend</b> shows the prompt that produced it &mdash; edit it and click <b>Copy resend command</b>, then paste to Kai: that rolls back to the parent version and regenerates a new branch. (To just restore a version as-is, tell Kai &ldquo;roll back to vX.Y.&rdquo;)</p>
<table><thead><tr><th>Version</th><th>Time (UTC)</th><th>Change</th><th>View</th><th>Prompt</th><th>Commit</th></tr></thead>
<tbody>
$rows
</tbody></table>
<p class=roll>Current live deck: <a href="../anchorage-agentic-launch-sprint.html" target=_blank>anchorage-agentic-launch-sprint.html</a> &nbsp;&middot;&nbsp; CLI rollback: <code>versions/rollback.sh vX.Y</code></p>
<script>
async function tp(v){
  var r=document.getElementById('prow-'+v), open=r.style.display!=='none';
  r.style.display=open?'none':'';
  if(open) return;
  var ta=document.getElementById('pta-'+v);
  if(ta.dataset.loaded) return;
  ta.dataset.loaded='1';
  if(ta.dataset.has==='yes'){ try{var x=await fetch('./prompts/'+v+'.txt');if(x.ok) ta.value=await x.text();}catch(e){} }
}
async function rs(v,parent){
  var ta=document.getElementById('pta-'+v), p=(ta.value||'').trim();
  var base=parent||'the previous version';
  var cmd='[Anchorage sprint deck] Roll back to '+base+' and re-run this prompt to develop a new version (branch from '+base+'):\n\n'+p;
  var m=document.getElementById('msg-'+v);
  try{ await navigator.clipboard.writeText(cmd); m.textContent='Copied. Paste to Kai to regenerate from '+base+'.'; }
  catch(e){ m.textContent='Copy failed — select the textarea text and copy manually.'; }
}
</script>
</body></html>
HTML
}

if [ "${1:-}" = "--reindex" ]; then gen_index; exit 0; fi

# prevent concurrent / recursive runs (portable lock; macOS has no flock)
LK="$VDIR/.lock.d"; mkdir "$LK" 2>/dev/null || exit 0; trap 'rmdir "$LK" 2>/dev/null' EXIT

DESC="${1:-edit}"
MAJOR=$(cat "$VDIR/.major" 2>/dev/null || echo 3)
LAST=$(ls "$VDIR"/v${MAJOR}.*.html 2>/dev/null | sed -E "s#.*/v${MAJOR}\.([0-9]+)\.html#\1#" | sort -n | tail -1)
MINOR=$(( ${LAST:--1} + 1 ))
VER="v${MAJOR}.${MINOR}"
NEWEST=$(ls -t "$VDIR"/v*.html 2>/dev/null | head -1)
if [ -n "$NEWEST" ] && cmp -s "$DECK" "$NEWEST"; then exit 0; fi   # unchanged -> no snapshot
cp "$DECK" "$VDIR/$VER.html"
# capture the prompt that drove this version, if one was staged
if [ -s "$VDIR/.prompt" ]; then cp "$VDIR/.prompt" "$VDIR/prompts/$VER.txt"; : > "$VDIR/.prompt"; fi
printf '%s\t%s\t%s\t%s\n' "$VER" "$(date -u +%Y-%m-%dT%H:%MZ)" "$(git rev-parse --short HEAD 2>/dev/null)" "$DESC" >> "$MAN"
gen_index
git add "$VDIR" >/dev/null 2>&1
git commit -q -m "snapshot $VER: $DESC" >/dev/null 2>&1
git push -q >/dev/null 2>&1 || { git pull --rebase -q >/dev/null 2>&1; git push -q >/dev/null 2>&1; }
echo "$VER"
