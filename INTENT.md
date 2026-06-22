# INTENT — Anchorage Agentic Preview (GTM campaign microsite + deck suite)

> Serves: ws:ws-deliver  — advances the "Deliver & retain Winn.solutions clients" North Star via the "Ship promised work" driver (the-sage/goals.json).

> **What this file is.** The *why* behind this deliverable — the job it does, the client's goals,
> the journeys stakeholders take through it, and the boundaries an agent must respect when working
> on it autonomously. Authored from the repo's own HISTORY (build prompts, version manifest, the
> rendered overview deck), **not** reverse-engineered from markup. The artifacts encode the pitch;
> this encodes intent. Loaded every session (see "Keep this true") so agents act from the goal.
>
> Provenance: authored 2026-06-22 from `index.html`, `anchorage-campaign-overview.html` (rendered
> text), `versions/manifest.tsv`, `versions/prompts/{v1.0,v3.0,v5.0}.txt`, `versions/snapshot.sh`,
> the top-level file/asset listing, and `git log`. No README, no `docs/`, no memory-bank existed —
> THIN history; ❓ tags are generous and should be confirmed with Jarred before any consequential edit.
> Confidence tags: ✅=stated verbatim in a source · 🟡=strongly implied by history · ❓=inferred, confirm.

## Job (the one true reason it exists)

When Anchorage's leadership needs to see and sign off on Winn.solutions' proposed agentic-banking
go-to-market campaign, they want a single, polished, confidential interactive artifact that shows
the whole launch — the narrative, the calendar, every content piece, the gates — so they can review,
react, and approve the work as ready-to-ship. 🟡

> The JOB is *client review + buy-in for a GTM campaign*, not "a website." The deck is the medium;
> the outcome is Anchorage trusting the plan enough to greenlight the launch. ❓ (confirm framing)

## Users & goals

Primary user: **Anchorage stakeholders** — the named review panel: Kate Roling, Erin DeMarco,
Joe McNaney, Sam Gentile, Jen Hunnewell. ✅ (named "PREPARED FOR" in the overview deck)
Operator/builder: **Jarred (Winn.solutions)** — authors the decks, runs the version/snapshot
machine, fields client revisions. ✅

What the Anchorage reviewers are actually trying to accomplish:
- **G1 — Judge whether this campaign is real and shippable** without overclaiming or compliance risk. ✅ ("Prove it is real, without overclaiming"; "zero overclaim leaks, the honesty KPI")
- **G2 — Understand the launch end-to-end at a glance** — narrative spine, sprint sequence, calendar, assets, owners, gates — to approve or redirect. 🟡
- **G3 — Comment / give feedback in their own tools** (Google Docs in comment mode, a spreadsheet "so Kate can comment"). ✅ (v5.0 prompt)
- **G4 — See the strategic frame** ("who banks the agents", the 7 pillars, 3 goals, 8-phase engine) so the launch reads as move one of a campaign, not a one-off. ✅

Builder goal (Jarred): ship a client-ready, on-brand, gate-clean deliverable that wins approval and
retains the engagement. 🟡

## Journeys (what the user is supposed to do, end-to-end)

> Tag the component(s) carrying each step — traceability for drift checks.

1. **Land (confidential entry) →** open the unlisted index → pick the priority deck or sprint one-pager.  *(components: `index.html`, `robots.txt`, `.nojekyll`, noindex meta)* ✅
2. **Get the frame →** read the master overview: the spine ("who banks the agents"), 7 pillars, 3 goals, the 8-phase engine, the 4-sprint roadmap.  *(components: `anchorage-campaign-overview.html`)* ✅
3. **Drill into the live launch →** open Sprint 1, the one sprint designed in full: launch calendar (T-minus, slotted by time not owner), every content piece tagged (Tweet / Live Interview / Research Paper), inline tweets that expand to full text + engagement + QTs + a sub-narrative comment layer.  *(components: `anchorage-agentic-launch-sprint.html`, `agentic-banking-launch-campaign.html`)* ✅
4. **Inspect the sub-sprints →** research paper (one Google Doc link at top), Nathan's hero video (play-button mockup → full script), Nathan's script, live interview (Ribbit/Tibber, with moderator), agentic recruiting bot (screenshot + play button → description).  *(components: sprint deck SS-1..SS-n; `assets/*.png` previews; `who-banks-the-agents*.{html,pdf}`)* ✅
5. **Preview the conversion surfaces →** waitlist landing-page screenshot with expandable callout side-notes; signup-order/referral framing.  *(components: `assets/waitlist-landing.png`, `assets/_src-waitlist-landing.html`)* ✅
6. **Comment & approve →** follow working Google Doc links (anyone-with-link, COMMENT mode) and the spreadsheet calendar; leave feedback; Winn.solutions turns revisions (see v3.0 = 17 client revisions).  *(components: external Google Docs/Sheets, linked from deck)* ✅
7. **Browse Sprints 2–4 (proposed) →** read stablecoins / settlement (Atlas) / AI-bank decks as principle-grade placeholders to design together later.  *(components: `anchorage-sprint2-stablecoins.html`, `anchorage-sprint3-settlement.html`, `anchorage-sprint4-aibank.html`)* ✅
8. **(Operator) Version & ship →** edit the live deck → `versions/snapshot.sh "desc"` auto-snapshots, records the producing prompt, regenerates the history index, and publishes; resend/branch a prior version from its prompt.  *(components: `versions/snapshot.sh`, `rollback.sh`, `manifest.tsv`, `versions/prompts/`)* ✅

## Success — from the user's point of view

- Anchorage reviewers can grasp the entire campaign in one sitting and either approve it or give precise revisions — without ever seeing an overclaim, a placeholder-as-promise, or an "AI wrote this" tell. ✅ (honesty KPI; v3.0: "as though we personally just wrote it ourselves")
- Every Google Doc / sheet link works and opens in comment mode. ✅ (v5.0: "None of the google doc links currently work" was the bug to kill)
- The deck reads as house-style Anchorage (brass-on-navy), confidential, and senior-ready — not a generic template. 🟡
- Client revisions round-trip fast; the version machine makes "ship the next round" a one-command, reversible act. 🟡

## Guardrails — boundaries for an agent working on this WITHOUT the operator

> This is a **client-facing deliverable for Anchorage, a federally-chartered crypto bank.** Treat
> every byte as something a financial-regulator-adjacent stakeholder may read. The bar is high.

- **THE ONE RULE (from the deck itself): every loud moment is backed by a real thing.** Tease only what is real now — the category, the initiative, the partner *relationships*, the waitlist. **GATE** (do NOT present as shipped/available): the platform as generally available, named capabilities, and volume/metric numbers. "Zero overclaim leaks" is the stated honesty KPI. ✅
- **Nothing publishes to a wider audience without review.** The site is deliberately unlisted/confidential (`noindex,nofollow`, `robots.txt`, `.nojekyll`, "Unlisted and confidential"). Never remove the noindex/robots protections; never make the site discoverable or share a public link without explicit operator sign-off. ✅
- **No "AI" tells in client-facing copy.** The research paper and all content must read as if Winn.solutions personally authored it and is handing a polished, publish-ready draft to Anchorage — no AI notations, no "here are different perspectives," no model meta-commentary. ✅ (v3.0)
- **Em dashes are banned in Nathan's tweets** (and treat as a strong signal for his voice generally). ✅ (v3.0)
- **Nathan content goes through the belief MCP** (subject `mccauley`, ~30–40 beliefs) + its style guide for tone; run a check that it was actually used. Nathan is a **blue check + Anchorage affiliate logo**, NOT a gold check — get verification badges right. ✅ (v1.0, v3.0)
- **Sprints 2–4 are PLACEHOLDERS — principle-grade framing only.** No committed capability, timeline, partner name, or volume number. Label as proposed/draft sequence, "not a commitment." Do not let a placeholder harden into a promise. ✅
- **Stakeholder names are real people who read this.** Don't refer to "the client" in copy they'll see; don't expose internal/compliance-review chrome to Anchorage ("Compliance and voice review seems completely erroneous for anchorage to see"). ✅ (v3.0/v5.0)
- **Money/partner claims stay at category altitude** — partner relationships teased, never a capability claim attached to a partner. ✅
- **Version/publish contract:** changes to the live deck take effect via `versions/snapshot.sh` (auto-snapshots only when changed, records the prompt, regenerates the index, pushes). `rollback.sh` is the recovery path. Don't hand-edit version history or bypass the snapshot machine. ✅
- **Do NOT auto-commit/publish a client deliverable on a guess.** Per the operator's own instruction for this task, INTENT/CLAUDE.md were authored without committing — apply the same conservatism to substantive deck edits: confirm before shipping a new client-visible round. ❓ (confirm threshold with Jarred)

## Key decisions / alternatives rejected (the reasoning code can't show)

- **One campaign run as a sprint sequence, not a single launch** — chose a reusable 8-phase "engine" instantiated per pillar so the launch reads as move one of a campaign. (Single big-bang launch rejected.) ✅
- **Waitlist (consumer-facing) over a design-partner CTA** — Anchorage wants consumer-facing signal, to measure excitement and remarket; "hype drives action before awareness of the product concept." (Design-partner CTA rejected.) ✅ (v5.0)
- **Launch *calendar* slotted by time, not a Gantt by owner** — relabeled from "gantt"; rows bundled by topic/connection and ordered by send sequence, not grouped by owner. ✅ (v3.0, v5.0)
- **One Google Doc link per section (top), not per tweet** — links concentrated, comment-mode, anyone-with-link. (Per-tweet doc links rejected as clutter.) ✅ (v5.0)
- **Research paper shown as screenshot + single review doc link**, scrubbed to publish-ready, rather than an inline AI-style draft. ✅ (v3.0)
- **Top section is a BELIEF→Hype→Launch→Convert phase map with stage-met checkboxes**, not a top-3 list. ✅ (v5.0)
- **The recruiting bot's own guardrails ARE the message** — its pre-reviewed jailbreak-refusals carry the accountability thesis (the product demonstrates the argument). ✅
- **Per-version producing-prompt captured + resendable** — versioning stores the prompt that made each version so any version can be branched/resent. ✅ (snapshot.sh)

## Keep this true (anti-rot + value)

- **Re-fed every session:** the project `CLAUDE.md` points to this file, so its job/guardrails are present each session and after `/compact` — a live tool, not a doc that rots.
- **Drift check:** each journey step names its component(s); a periodic pass asks "does this component still serve this step, and does any guardrail (especially the clean-vs-gated honesty rule) now fail?"
- **Update trigger:** when the *why* changes — a new sprint graduates from placeholder to live, the honesty/gating rule moves, the stakeholder panel changes, or the publish/confidentiality posture changes — edit Job/Journeys/Guardrails here in the same session, same discipline as a commit.
- **THIN-history caveat:** this was authored without a README or memory-bank. Resolve the ❓ lines with Jarred and upgrade their tags as you confirm.
