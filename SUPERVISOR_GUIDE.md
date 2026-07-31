# Daily Market Brew — Supervisor Guide

## Your Role

You approve (or edit, or reject) the day's draft in the WhatsApp working group.

## The Command Options

You have exactly these commands:

### APPROVE

Accept all proposed choices:
- The proposed 5 intelligence items
- All Events Ahead day-groups
- Current scorecard figures

**When to use:** Proposed 5 is good as-is

**Example:** 
```
APPROVE
```

---

### APPROVE PICK n,m,o,p,q

Override the proposed 5 with your custom 5.
The system validates that your picks maintain tier distribution.

**When to use:** You want different items than proposed

**Example:** 
```
APPROVE PICK 1,3,8,11,14
```

---

### APPROVE EVENTS n,m,o

Choose which Events Ahead day-groups to include.
Leave blank to drop Events Ahead section entirely.

**When to use:** Some events are less important today

**Example:** 
```
APPROVE EVENTS 1,2
```

---

### EDIT HEADLINE <new text>

Replace the headline (max 15 words).

**Example:** 
```
EDIT HEADLINE Asia Rallies on China Stimulus; Fed Awaits Data
```

---

### EDIT BULLET <n> <text>

Replace one of the 6 wrap bullets (max 40 words).

**Example:** 
```
EDIT BULLET 3 Nikkei 225 rose 2.1%, reversing last week's weakness.
```

---

### EDIT <n> <text>

Replace one of the 15 candidate items (25-40 words, entity-first).

**Example:** 
```
EDIT 7 Samsung Electronics beat Q2 earnings forecast, guiding higher for memory chip demand.
```

---

### REJECT <reason>

Stop the day. The desk falls back to manual.

**Example:** 
```
REJECT Data looks stale on FX moves
```

---

### STATUS

Show current stage and outstanding items.

**Example:** 
```
STATUS
```

---

### HOLD <minutes>

Delay dispatch by N minutes (e.g., `HOLD 30`).

**Example:** 
```
HOLD 30
```

---

## Timeline

- **08:05 UTC (08:05 MYT):** Draft posted to working group
- **~07:55 MYT:** Bloomberg email arrives (Part 3 data)
- **~12:00 MYT:** Bloomberg figures reconciled, ready for final approval
- **By 12:15 MYT:** You give final approval
- **12:20 MYT:** Dispatches to advisor groups

---

## Quick Tips

- **The numbers matter.** Every figure comes from Bloomberg or Reuters. We don't invent data.
- **Edit with care.** Editing changes the hash and requires re-validation.
- **Check the sources.** All 5 items must come from Reuters, Bloomberg, CNBC, or FT.
- **Trust the validator.** If the system says something fails, fix it — the validator doesn't hallucinate.

---

## Examples of Good Edits

❌ Bad: `EDIT 3 Bitcoin soared 5%`  
(Too vague, no source)

✅ Good: `EDIT 3 Bitcoin surged 5% on expectation of US spot ETF approval, per Reuters.`  
(Entity-first, figure, source, why it matters)

---

## Support

- **Is a command wrong?** Check the exact syntax above.
- **Does the draft look odd?** Check sources before approving.
- **Is something missing?** Post STATUS to see what stage we're in.
- **Emergency stop?** Post REJECT <reason> and tell the team.

**On-call:** [@oncall-slack]
