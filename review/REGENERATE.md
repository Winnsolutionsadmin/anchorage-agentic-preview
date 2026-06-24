# Deck feedback → accept/deny → regenerate (the loop)

The full internal team-collaboration loop for the Anchorage deck. No SaaS, no paid tool.

## 1. Capture — team leaves per-item feedback on the live deck
- Review link (send the team): the `…-review.html` page on GitHub Pages.
- They click **✎ Review**, then click any element → leave a comment. Comments persist (localStorage).
- Per comment they choose:
  - **File issue ↗** → opens a GitHub *new issue* in `anchorage-deck-feedback`, prefilled with the
    target text, section, selector, deck version, and their comment, labeled `feedback`. They click Submit.
    (Needs a GitHub login — fine for the internal Winn team.)
  - **Export JSON / Copy Markdown** → batch the whole set and send Jarred (no GitHub login needed).

## 2. Triage — Jarred accepts / denies (2 clicks each)
On `Winnsolutionsadmin/anchorage-deck-feedback` issues, label each:
- `accepted` → Kai will apply it.
- `denied` → won't apply (close as not-planned with a one-line why).
Leave untriaged ones as just `feedback`. (Optional: a Project board with Inbox/Accepted/Denied columns.)

## 3. Handoff → Kai regenerates the next version (via the SSOT pipeline)
Kai pulls the accepted set and regenerates — never hand-edits the rendered deck:

```
gh issue list -R Winnsolutionsadmin/anchorage-deck-feedback --label accepted \
  --state open --json number,title,body
```

For each accepted item, edit the **source** in the `anchorage-sprint-ssot` repo:
- Calendar / phase-map / subsprints / action-items content → the matching **`*.json`** file.
- Hero / conversion / partner / SS-1 / SS-6 / CSS → **`deck.template.html`**.

Then regenerate + self-verify (validates 53 checks, renders, leak-sweeps — never writes the live deck):

```
.venv/bin/python build.py /tmp/deck.regen.html      # must print PASS
```

Promote to live (only after PASS):
```
cp /tmp/deck.regen.html  ~/Projects/anchorage-agentic-preview/anchorage-agentic-launch-sprint.html
python3 review/build-review.py                       # refresh the review copy
git add -A && git commit -m "vN: apply accepted feedback (#<issues>)" && git push
# autosnapshot hook mints the next version; close each applied issue, label `applied`.
gh issue close <n> -R Winnsolutionsadmin/anchorage-deck-feedback --comment "Applied in vN"
```

## Operating rules
- **The SSOT repo is the source of truth.** Don't hand-edit the live deck after this, or the SSOT
  template drifts. All deck changes flow: edit SSOT source → `build.py` → promote.
- The review overlay is a **wrapper** (`build-review.py`), not part of the SSOT source — re-run it
  after every regenerate to refresh the review copy.
- Every promote auto-snapshots a version (`versions/`), so every state is revertible.
- Client Google Docs are **read-only leaves** (`doc-targets.json`) — never auto-regenerated
  (regenerating would destroy client comments). Promote those by hand, per doc, on instruction.
