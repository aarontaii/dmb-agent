---
name: dmb-macro-events
description: Maintains the DMB macro events store from the TradingEconomics calendar. Weekly seed of the coming week, daily refresh that captures actuals and logs reschedules.
metadata: { "openclaw": { "emoji": "🗓️", "requires": { "bins": ["python3"] } } }
---

# Context

Replaces the manual TradingEconomics filter-and-paste. Countries in scope: United States,
China, Euro Area, Japan, Malaysia. Store: `state/events/YYYY-Www.json` plus an append-only
`state/events/changelog.jsonl`. Schema and rules: design doc Part C.

# Instructions

## Mode: seed (weekly, Monday 05:45 MYT)

1. `python3 {baseDir}/scripts/te_calendar.py seed --from <mon> --to <sun>`.
2. The script fetches, parses, filters to the five markets and the configured importance
   floor, and validates that the returned rows actually fall inside the requested window.
   If validation fails it exits non-zero: do not write a store from an unvalidated fetch.
3. Report to the working group: total events, per-country counts, and the high-impact ones
   named with their weekday. One short paragraph, no table.

## Mode: refresh (daily, before drafting)

1. `python3 {baseDir}/scripts/te_calendar.py refresh --target <target_session_date>`.
2. The script fills `actual` and sets `status: done` for events dated on or before the
   target session date, appends newly-seen events, marks moved events `rescheduled` with
   `rescheduled_from`, marks vanished events `cancelled`, and writes every change to the
   changelog.
3. Return a compact diff summary for the editorial footer: actuals captured, new events
   found, reschedules, cancellations. "No changes" is a valid summary.

# Error handling

- Fetch fails or markup unrecognised: return the failure plainly and leave the store
  untouched. A stale store that is known stale beats a silently corrupted one.
- Window validation fails: same. Never overwrite a good week with a wrong week.
- Store file missing on a refresh: run seed for the current week first, then refresh.

# Rules

- The store is the only source of events. Do not answer "what is due this week" from memory.
- Never delete an event. Cancelled events keep their row with `status: cancelled`.
- Store both ET and MYT timestamps. Do not derive one at render time.
- Events Ahead reads only `status == pending` and `date > target_session_date`.

# Output format

Seed: one paragraph summary. Refresh: a four-line diff summary. Nothing else.
