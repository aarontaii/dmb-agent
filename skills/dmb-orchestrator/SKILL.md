---
name: dmb-orchestrator
description: Runs the iFAST Daily Market Brew daily pipeline end to end, from events refresh to posting the review pack in the working group. Never sends to advisor groups.
metadata: { "openclaw": { "emoji": "📣" } }
---

# Context

You coordinate the Daily Market Brew (DMB) for the iFAST MY Research team. You do not
write the note yourself: you sequence the other dmb-* skills, hold the run record, and
post a review pack to the DMB working group. You never dispatch to advisor groups —
only `dmb-dispatch`, after an approval, does that.

Spec: `../../DMB_OpenClaw_Conversion_Design.md` Part E. State root: `{baseDir}/../../state`.

# Instructions

1. Resolve the target session. Mon -> prior Friday (plus Sat-Sun sweep), Tue -> Mon,
   Wed -> Tue, Thu -> Wed, Fri -> Thu. Anchor datelines to US Eastern. Call the
   deterministic helper; do not compute dates in prose.
2. Write `state/drafts/<today>/run.json` with `{ run_id, started_at, target_session_date,
   weekday, stage: "drafting" }`.
3. Run `dmb-macro-events refresh` for the target window. Record the diff summary.
4. Look up each market's closure status for the target date in `state/holidays/2026.yaml`
   (NYSE/Nasdaq, HKEX, JPX/TSE, SSE, SGX, Bursa, Euronext). Check each market
   independently; never infer one closure from another.
5. Run `dmb-draft`. It returns structured Part 1 content, 15 ranked candidate items with
   a proposed 5, Key Takeaways, and the editorial footer facts.
6. Run `dmb-validate` on the draft. If it fails, fix and re-validate. Do not post a
   draft that has not passed.
7. Write the complete review pack to `state/drafts/<today>/review-pack.txt`. This is
   the canonical on-disk copy.
8. `sessions_send` the complete review pack as a single message to `agent:dmb:main`
   so the supervisor can read the full draft in webchat. This is best-effort; the
   on-disk copy in step 7 is the fallback.
9. Update `run.json` stage to `awaiting_figures`.
10. Your final reply IS the full review pack for WhatsApp delivery. The cron announce
    delivers your final reply directly to the working group without triggering agent
    processing. Structure it in this exact order (most critical content first):

    ```
    📋 *DMB Review Pack* | Run: <run_id>
    Target: <day>, <date> | Hash: <hash>
    Validator: <result> | Stage: awaiting_figures

    ─── *Message 1 — Market Moves* ───
    📣 *iFAST Daily Market Brew* 📣
    *<dateline>*
    *<headline>*
    [scorecard table — all 9 indices with levels and % changes, one per line]
    [5 bullets]
    [Events Ahead — prose per day-group, or "No major events scheduled ahead" when empty]

    ─── *Message 2 — 15 Candidate Items* ───
    *TIER 1* (list all T1 items with [rank] number, ⭐ if starred, full text)
    *TIER 2* (list all T2 items same format)
    *TIER 3* (list all T3 items same format)
    *Proposed 5*: <rank numbers> (one-line reason each)
    *Rejected 10*: <rank numbers> (one-line reason each)
    ✅ *Key Takeaways*: <full text>

    ─── *Message 3 — Part 3 & Footer* ───
    ⚠️ Part 3 PENDING — Bloomberg data not yet wired
    [Editorial Footer — dominant narrative, closures, source conflicts, events diff, FX check]
    On-disk: `state/drafts/<today>/review-pack.txt`

    *Commands*: APPROVE · APPROVE PICK a,b,c,d,e · APPROVE EVENTS a,b,c · EDIT <n> <text> · EDIT HEADLINE <text> · EDIT BULLET <n> <text> · REJECT <reason> · STATUS · HOLD <minutes>
    ```

    The final reply is posted to the WhatsApp working group via the cron announce
    delivery. This is the PRIMARY delivery path — it bypasses the working group
    agent session and posts directly. The content MUST be complete: all 15
    candidate items with their rank numbers, the proposed 5 with reasons, and
    the rejected 10 with reasons. Never abbreviate or omit candidate items.
    Scorecard and Part 3 figures are marked PENDING until Bloomberg lands.

# Error handling

- Events store missing or short for the week: re-seed before refreshing, and say so in the pack.
- Web search unavailable: post "Web search unavailable, cannot produce this report" to the
  working group and stop. Do not draft from memory.
- Any stage throws: post what you have, name the failed stage, set stage to `blocked`.

# Rules

- Never send to an advisor group.
- Never invent a figure. Every number traces to the events store, the Bloomberg file, or a
  fetched source snapshot saved under `state/drafts/<today>/sources/`.
- Never publish placeholder text. A PENDING marker is allowed in the working group only.
- You run unattended: the final reply is the deliverable, not a plan or a question.

# Output format

Your final reply IS the full review pack — it is delivered to the WhatsApp working
group via the cron announce mechanism, which posts directly without agent processing.
This is the only reliable path for getting all 15 candidate items into WhatsApp.

Additionally:
- `sessions_send` the full review pack to `agent:dmb:main` (webchat, best-effort)
- Write it to `state/drafts/<today>/review-pack.txt` (on-disk fallback)
