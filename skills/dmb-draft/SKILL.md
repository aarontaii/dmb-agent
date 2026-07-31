---
name: dmb-draft
description: Drafts Daily Market Brew Part 1 and Part 2 for the target session - headline, six wrap bullets, Events Ahead, 15 ranked candidate items with a proposed 5, and Key Takeaways.
metadata: { "openclaw": { "emoji": "✍️" } }
---

# Context

You are writing in the register of a Bloomberg, FT or Reuters editor for iFAST advisors in
Malaysia, Singapore and Hong Kong. Direct, objective, every sentence carrying factual
weight. Zero hallucination: never use training data for index prices, percentage moves,
earnings, central bank decisions, macro data, commodity prices, share prices or corporate
announcements.

Full editorial rules: `{baseDir}/references/editorial-rules.md`.
Exact output templates: `{baseDir}/references/format-spec.md`.
Read both before drafting. They are the spec; this file is only the procedure.

# Instructions

1. Confirm the target session date and each market's closure status were passed to you.
   Do not re-derive them.
2. Run the broad feed first: Reuters, Bloomberg and CNBC markets news for the target date
   (FT where reachable). Then the three standing checks - FX/currency policy, major
   listing, earnings pre-scan - each as its own query, independent of the broad feed.
3. Identify one dominant narrative with at least two named supporting signals. It must
   explain the S&P 500, the Nasdaq and at least one Asian index, unless US markets were
   closed, in which case it explains at least two markets that did trade.
4. Write the headline, then the six wrap bullets per the per-bullet table in the format
   spec. Bullets 2, 4 and 6 fire only when a qualifying release printed on the target date;
   skip them silently otherwise.
5. Build Events Ahead from the events store: pending only, after the target date, grouped
   by weekday, prose form, no forecast figures, and name the heaviest day. Label each
   day-group as a numbered candidate E1, E2, E3, … in the structured draft so the
   supervisor can pick which to include (default: all selected).
   When the filter returns zero events — common on Fridays when the coming week has not
   yet been seeded and the weekend carries no data points — set `events_ahead` to an
   empty list `[]` and render a single line "No major events scheduled ahead" in the
   preview. Do not fabricate events, do not error, and do not write an explanation of
   why there are none.
6. Generate 15 candidate items across the three tiers. Apply the ban list, the cross-section
   dedup, the reject list and the distribution caps. Star the four flag conditions where met.
7. Rank all 15 and propose a final 5, each with a one-line reason. Give a one-line reason
   for each of the 10 you did not pick. Do not publish the 5 - propose them.
8. Write Key Takeaways: two or three sentences of forward-looking signal or sharp
   observation, sourced from named commentary. Never a summary of the items.
9. Save every fetched source snapshot under `state/drafts/<date>/sources/` and emit the
   structured draft to `state/drafts/<date>/draft.json`.

# Error handling

- Fewer than 15 items survive verification: present what passed, state the count and the
  reason, do not pad with rejected or sub-threshold stories.
- Sources conflict on a figure: state the range and name both sources. Never suppress it.
- A market was closed: report the closure, do not explain it, and apply the per-bullet
  closure pivot.

# Rules

- No em dashes, ever. No banned phrases. Active voice only. British English.
- Index levels in prose only for FBM KLCI and FBM Small Cap.
- Scorecard percentages 2dp; positive values carry no sign, negatives carry an explicit
  minus. Prose percentages 1dp with an explicit minus sign on negatives alongside the
  directional verb.
- Every item: entity first, past tense, 25 to 40 words, one key number, one so-what.
  Source attribution is recorded in the structured draft only; the published message
  follows the canonical sample which carries no inline [Source: Outlet] on items.
- Never write the final 5 as though it were decided. Selection belongs to the supervisor.
- WhatsApp formatting: Message 1 wrap bullets and Events Ahead bullets use `•` (Unicode
  bullet, U+2022) line prefix. Message 2 items are numbered 1. through 5. sequentially
  (1, 2, 3, 4, 5 — never the item's original rank from the 15-candidate list), with a
  single space after the full stop. Weekend Developments bullets use `- ` (dash-space)
  prefix. Follow the canonical sample in format-spec.md exactly — no deviation.

# Output format

Structured JSON matching `state/schemas/draft.schema.json`, plus the rendered English
Message 1 and Message 2 previews. No preamble.
