#!/usr/bin/env python3
"""Wrap the live deck into an internal Marker.io review copy (snippet in <head>).
Client deck is never touched. Re-run after any deck version to refresh.
    python3 review/build-marker.py
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECK = os.path.join(ROOT, "anchorage-agentic-launch-sprint.html")
SNIP = os.path.join(ROOT, "review", "marker-snippet.html")
OUT  = os.path.join(ROOT, "anchorage-agentic-launch-sprint-marker.html")
html = open(DECK, encoding="utf-8").read()
snip = open(SNIP, encoding="utf-8").read().strip()
out = html.replace("</head>", snip + "\n</head>", 1) if "</head>" in html else snip + html
open(OUT, "w", encoding="utf-8").write(out)
print("wrote", OUT, "| marker shim present:", "edge.marker.io" in out, "| bytes:", len(out))
