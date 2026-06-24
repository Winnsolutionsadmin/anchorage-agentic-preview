#!/usr/bin/env python3
"""Wrap the live deck into a self-contained REVIEW copy with the feedback overlay.
Reads the live deck + review/overlay.js, injects a version stamp + the overlay before
</body>, writes anchorage-agentic-launch-sprint-review.html at the repo root (same Pages dir).
The master/client deck is never modified. Re-run after any deck version to refresh the review copy.

    python3 review/build-review.py
"""
import os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECK = os.path.join(ROOT, "anchorage-agentic-launch-sprint.html")
OVERLAY = os.path.join(ROOT, "review", "overlay.js")
OUT = os.path.join(ROOT, "anchorage-agentic-launch-sprint-review.html")


def git(*a):
    try:
        return subprocess.check_output(["git", "-C", ROOT] + list(a), text=True).strip()
    except Exception:
        return ""


def main():
    html = open(DECK, encoding="utf-8").read()
    overlay = open(OVERLAY, encoding="utf-8").read()

    major = ""
    mp = os.path.join(ROOT, "versions", ".major")
    if os.path.exists(mp):
        major = "v" + open(mp).read().strip()
    commit = git("rev-parse", "--short", "HEAD")
    version = (major + " (" + commit + ")") if commit else (major or "deck")

    stamp = ('<script>window.__REVIEW_DECK_VERSION__=' + repr(version).replace("'", '"') + ';</script>')
    block = "\n" + stamp + "\n<script>\n" + overlay + "\n</script>\n"

    if "</body>" in html:
        out = html.replace("</body>", block + "</body>", 1)
    else:
        out = html + block

    # keep it noindexed/unlisted like the master
    open(OUT, "w", encoding="utf-8").write(out)
    print("wrote", OUT)
    print("deck version stamped:", version)
    print("bytes:", len(out), " overlay injected:", "rvw-fab" in out)


if __name__ == "__main__":
    main()
