---
name: dmb-market-data
description: Ingests the daily Bloomberg Morning Brew Data email, parses indices, MGS/UST yields and FX rates, and reconciles them against the drafted figures.
metadata: { "openclaw": { "emoji": "📊", "requires": { "bins": ["python3"] } } }
---

# Context

The email arrives at roughly 07:30 MYT in the research group inbox from
`mybloomberg3@ifastfinancial.com`, subject `[YYMMDD]_Morning Brew Data`. It carries the
nine index changes (into Part 1), MGS 3/5/10/20Y and UST 2/5/10/20Y yields, and nine FX
pairs (into Part 3). Bloomberg is the authoritative source for every price in the note.

# Instructions

1. `python3 {baseDir}/scripts/parse_bloomberg_email.py --date <today>` — fetches the
   message, parses it, writes `state/marketdata/<date>.json`.
2. Refuse to continue if any of the 9 indices, 8 yields or 9 FX pairs is missing. Partial
   data is a hold, not a degraded send.
3. Reconcile every index level and percentage against the web-verified figures already in
   `state/drafts/<date>/draft.json`. Tolerances: percentage within 0.05pp, level within
   0.1 percent, direction must match.
4. Direction mismatch is always a block. Magnitude beyond tolerance is a block. Post both
   values and the delta to the working group and ask the supervisor to adjudicate.
5. On a clean reconcile: overwrite the scorecard with the Bloomberg figures, render Part 3
   from the template, set stage `ready_for_review`, and repost the pack with figures complete.
6. If no email by 07:55 MYT, alert the working group. Hold the draft. Never send with
   PENDING figures.

# Rules

- The scorecard is Bloomberg's numbers, not the web's. The web numbers exist only to be
  cross-checked.
- Part 3 involves no judgement: fixed pair order, yields 2dp with bps to 1dp, FX 4dp with
  percentage to 2dp, disclaimer line mandatory, English only, never translated.
- Do not "fix" a Bloomberg figure that looks odd. Flag it against the sanity ranges and
  let a human decide.

# Output format

Either a one-line "reconciled, figures complete" plus the updated pack, or a block notice
naming each disagreeing field with both values.
