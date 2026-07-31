# iFAST Daily Market Brew Agent — Complete Setup & Distribution Guide

**Version:** 1.0  
**System:** DMB Agent with 9 integrated skills  
**Status:** Production Ready  
**Created:** 2026-07-31

---

## Overview

The iFAST Daily Market Brew (DMB) is an **autonomous daily research workflow** that:
- Monitors macro events and market moves
- Drafts market intelligence with editorial oversight
- Validates content against strict rules
- Handles supervisor approval and edits
- Translates to Chinese
- Distributes to advisor WhatsApp groups

**9 coordinated OpenClaw skills** orchestrate the entire pipeline from data refresh to advisor delivery.

---

## The 9 Skills

| Skill | Purpose | Triggered | Owner |
|-------|---------|-----------|-------|
| **dmb-orchestrator** | Sequence the pipeline, hold run records | Daily cron | System |
| **dmb-macro-events** | Maintain macro calendar from TradingEconomics | Weekly seed + daily refresh | System |
| **dmb-draft** | Write headline, bullets, candidates, Key Takeaways | After events refresh | Agent |
| **dmb-market-data** | Ingest Bloomberg email, parse yields/FX, reconcile | ~07:55 MYT daily | System |
| **dmb-validate** | Deterministic pre-send validation (word counts, formatting, tiers) | Every stage | System |
| **dmb-review-gate** | Handle supervisor commands (APPROVE, EDIT, REJECT) in WhatsApp | Working group | Agent |
| **dmb-translate** | Translate English to Chinese, re-apply formatting | After approval | Agent |
| **dmb-dispatch** | Send to advisor groups (MY, SG, HK) | After approval | System |
| **dmb-market-brew** | *Optional:* Monitor WhatsApp groups, aggregate market signals | If enabled | Optional |

---

## System Architecture

### Daily Workflow (Mon–Fri)

```
┌─ ORCHESTRATOR (00:05 UTC / 08:05 MYT)
│
├─ Resolve target session date (Mon→prior Fri, Tue→Mon, etc)
├─ MACRO-EVENTS refresh (TradingEconomics)
├─ Check market closures (holidays.yaml)
│
├─ DRAFT (agent)
│   ├─ Reuters/Bloomberg/CNBC news search
│   ├─ Find dominant narrative
│   ├─ Write headline (≤15 words)
│   ├─ Write 6 wrap bullets
│   ├─ Identify 15 candidate items
│   ├─ Propose 5 to send
│   └─ Key Takeaways
│
├─ VALIDATE (draft stage)
│
├─ Post review pack to working group
│   └─ Full 15 candidates + proposed 5
│   └─ Wait for supervisor
│
├─ MARKET-DATA waits for Bloomberg email (~07:55 MYT)
│   ├─ Parse indices, yields, FX
│   ├─ Reconcile against draft
│   └─ Render Part 3
│
├─ REVIEW-GATE (working group, real-time)
│   ├─ Supervisor sees command choices:
│   │   • APPROVE (accept proposed 5)
│   │   • APPROVE PICK 2,5,7,9,13 (override)
│   │   • EDIT ... (modify)
│   │   • REJECT (stop the day)
│   └─ VALIDATE after edits
│
├─ TRANSLATE (to Chinese)
│   ├─ Message 1 (Market Moves) → Chinese
│   ├─ Message 2 (Intelligence) → Chinese
│   └─ Part 3 stays English only
│
└─ DISPATCH (to advisor groups)
    ├─ Send Message 1 EN → all 3 regions
    ├─ Send Message 1 CN → all 3 regions
    ├─ Send Message 2 EN → all 3 regions
    ├─ Send Message 2 CN → all 3 regions
    ├─ Send Message 3 (Part 3) → all 3 regions
    └─ Write receipts per region per message
```

### State Structure

```
state/
├── drafts/
│   └── YYYY-MM-DD/
│       ├── run.json                 [run_id, stage, timestamps]
│       ├── draft.json               [structured draft, candidate items]
│       ├── decision.json            [approval, picks, events_ahead]
│       ├── final.msg1.en.txt        [approved Message 1 English]
│       ├── final.msg1.cn.txt        [translated Message 1 Chinese]
│       ├── final.msg2.en.txt        [approved Message 2 English]
│       ├── final.msg2.cn.txt        [translated Message 2 Chinese]
│       ├── final.msg3.txt           [Part 3, English only]
│       ├── review-pack.txt          [canonical on-disk copy of review pack]
│       ├── receipts.jsonl           [per-group per-message send receipts]
│       └── sources/
│           └── [snapshots of fetched articles]
│
├── events/
│   ├── 2026-W30.json                [macro events for week 30]
│   ├── 2026-W31.json
│   └── changelog.jsonl              [append-only log of changes]
│
├── marketdata/
│   ├── 2026-07-31.json              [parsed Bloomberg data]
│   └── reconciliation.jsonl         [index/yield/FX reconciliation log]
│
└── holidays/
    └── 2026.yaml                    [NYSE/Nasdaq/HKEX/JPX/SSE/SGX/Bursa/Euronext closures]
```

---

## Installation & Setup

### Prerequisites

For **team members** running the system:

- **OpenClaw CLI** installed and configured
- **Python 3.8+** (for scripts)
- **API Access:**
  - TradingEconomics API key (free tier available)
  - Gmail access to Bloomberg email account (`mybloomberg3@ifastfinancial.com`)
  - WhatsApp Business API credentials (for dmb-dispatch)
  - Optional: Firecrawl API key (if using dmb-market-brew)

- **Permissions:**
  - Read access to TradingEconomics calendar
  - Gmail: Read Bloomberg email
  - WhatsApp: Send to 3 advisor groups (MY, SG, HK)
  - Write access to `state/` directory

### Quick Install

```bash
# 1. Get the skill package
git clone https://github.com/ifastfinancial/dmb-agent.git
cd dmb-agent/

# 2. Install all 9 skills
for skill in skills/dmb-*/; do
  openclaw install "$skill"
done

# 3. Set up configuration
mkdir -p state/{drafts,events,marketdata,holidays}
cp config/holidays.example.yaml state/holidays/2026.yaml
cp config/te_calendar.env.example .env

# 4. Configure each skill
./scripts/setup-dmb.sh

# 5. Test end-to-end
openclaw dmb-orchestrator --test --date 2026-07-31

# 6. Schedule daily run
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"  # 05:00 UTC (08:00 MYT) weekdays
```

---

## Configuration Files

### 1. TradingEconomics Calendar (`config/te_calendar.env`)

```bash
# TradingEconomics API
TE_API_KEY="your_api_key"
TE_COUNTRIES="US,CN,EUAREA,JP,MY"
TE_IMPORTANCE_FLOOR=3              # 1=low, 3=medium, 4=high
TE_FETCH_TIMEOUT=30               # seconds
```

### 2. Market Holidays (`state/holidays/2026.yaml`)

```yaml
holidays_2026:
  nyse:
    - date: 2026-01-01
      name: "New Year's Day"
  nasdaq: [same as NYSE]
  hkex:
    - date: 2026-01-29
      name: "Lunar New Year"
  jpx:
    - date: 2026-01-11
      name: "Coming of Age Day"
  sse: [...]
  sgx: [...]
  bursa:
    - date: 2026-07-07
      name: "Aidilfitri"
  euronext: [...]
```

### 3. Advisor Groups WhatsApp IDs (`config/dmb-dispatch.json`)

```json
{
  "regions": {
    "MY": {
      "group_id": "1234567890123456789@g.us",
      "name": "iFAST Malaysia Advisors",
      "approvers": ["+60123456789", "+60187654321"]
    },
    "SG": {
      "group_id": "9876543210987654321@g.us",
      "name": "iFAST Singapore Advisors",
      "approvers": ["+6581234567"]
    },
    "HK": {
      "group_id": "5555666677778888888@g.us",
      "name": "iFAST Hong Kong Advisors",
      "approvers": ["+85298765432"]
    }
  },
  "working_group_id": "1111111111111111111@g.us",
  "working_group_name": "DMB Research Team"
}
```

### 4. References (Read-only, included)

- `references/format-spec.md` — Output templates (canonical)
- `references/editorial-rules.md` — Writing guidelines

---

## Operation

### Monitoring

View the pipeline status:

```bash
# Watch today's run
openclaw dmb-orchestrator --watch

# View all recent runs
openclaw dmb-orchestrator --list --limit 7

# Check specific run
openclaw dmb-orchestrator --status --date 2026-07-31

# Stream logs
openclaw dmb-orchestrator --logs --follow
```

### Supervisor Controls (in WhatsApp working group)

```
APPROVE                           → Accept proposed 5 items
APPROVE PICK 2,5,7,9,13          → Override with custom 5
APPROVE EVENTS 1,2,4             → Select which events to include
EDIT HEADLINE <text>             → Modify headline
EDIT BULLET <n> <text>           → Modify wrap bullet
EDIT <n> <text>                  → Modify candidate item
REJECT <reason>                  → Stop the day
STATUS                           → Show current stage
HOLD 30                          → Delay dispatch by 30 minutes
```

### Manual Triggers

```bash
# Run full pipeline for a date
openclaw dmb-orchestrator --run --date 2026-07-31

# Just refresh events
openclaw dmb-macro-events refresh --target 2026-07-31

# Draft only (assumes events already refreshed)
openclaw dmb-draft --date 2026-07-31

# Parse Bloomberg email
openclaw dmb-market-data --date 2026-07-31

# Validate a draft
openclaw dmb-validate --draft state/drafts/2026-07-31/draft.json

# Translate to Chinese
openclaw dmb-translate --date 2026-07-31

# Dispatch to advisor groups
openclaw dmb-dispatch --date 2026-07-31 --region MY SG HK
```

---

## Skill Details

### 1. dmb-orchestrator 📣

**Role:** Conductor of the pipeline  
**Triggered:** Daily cron (05:00 UTC / 08:00 MYT)  
**Does:**
- Resolves target session date
- Sequences other skills
- Holds run state and timestamps
- Posts review pack to working group
- Never sends to advisor groups

**Inputs:** Target date, market closures  
**Outputs:** Review pack to working group, run.json

**Fails if:** Any stage errors, returns error message + stops

---

### 2. dmb-macro-events 🗓️

**Role:** Calendar maintenance  
**Triggered:** 
- Weekly seed (Monday 05:45 MYT)
- Daily refresh (before drafting)

**Does:**
- Fetches TradingEconomics calendar
- Filters to 5 markets (US, CN, EU, JP, MY)
- Captures actuals and reschedules
- Maintains append-only changelog

**Inputs:** Target date/window, importance floor  
**Outputs:** `state/events/YYYY-Www.json`, changelog.jsonl

**Fails if:** API unreachable, leaves store untouched (known-stale beats corrupted)

---

### 3. dmb-draft ✍️

**Role:** Content creation (agent)  
**Triggered:** After events refresh  
**Writes:** Headline, 6 wrap bullets, 15 candidate items, Key Takeaways

**Does:**
- Reuters/Bloomberg/CNBC web search
- Identifies dominant narrative
- Writes per editorial rules & format spec
- Returns structured draft + proposed 5

**Inputs:** Target session date, market closures, events  
**Outputs:** `draft.json` with all candidates

**Fails if:** Web search unavailable, returns "cannot produce"

---

### 4. dmb-market-data 📊

**Role:** Bloomberg data ingestion  
**Triggered:** ~07:55 MYT (when email arrives)  
**Does:**
- Fetches Bloomberg Morning Brew email
- Parses 9 indices, 8 yields, 9 FX pairs
- Reconciles vs draft (within tolerances)
- Renders Part 3
- Updates run.json stage

**Inputs:** Bloomberg email, draft scorecard  
**Outputs:** Part 3 (yields, FX), reconciliation log

**Fails if:**
- Email missing by 07:55 MYT → alerts working group
- Reconciliation fails → posts both values, asks supervisor to adjudicate
- Any data missing → refuses partial

---

### 5. dmb-validate 🧪

**Role:** Deterministic rule validator  
**Triggered:** Every stage  
**Runs:** Python script checking ~20 rules

**Validates:**
- ✓ Word counts (headline ≤15, bullets ≤40, Key Takeaways ≤3 sentences)
- ✓ Formatting (single asterisks, no em dashes, no banned phrases)
- ✓ Scorecard (9 indices, 2dp, comma thousands, sanity bands)
- ✓ Items (5 in final, 25-40 words, entity-first, past tense, source on allowlist)
- ✓ Tier distribution (caps on geopolitical, corporate, sectors)
- ✓ Ban list (no index reuse, no company twice)
- ✓ No placeholders (PENDING, TODO, XX)
- ✓ Cross-check percentages match scorecard

**Inputs:** Draft or final files, language (en/cn)  
**Outputs:** Pass/fail report with specific failures

**Fails if:** Any blocking rule violated, returns detailed fix required

---

### 6. dmb-review-gate ✅

**Role:** Supervisor approval handler (agent in working group)  
**Triggered:** Every message in working group  
**Responds to:** APPROVE, EDIT, REJECT, STATUS, HOLD

**Does:**
- Verifies sender is approver (E.164 allowlist)
- Parses command
- Applies edits, re-validates
- Writes decision.json
- Gates dispatch

**Inputs:** Supervisor command, draft.json  
**Outputs:** decision.json, feedback to group

**Fails if:** Sender not approver → alerts group

---

### 7. dmb-translate 🀄

**Role:** English to Chinese translation  
**Triggered:** After approval  
**Does:**
- Translates Message 1 (Market Moves)
- Translates Message 2 (Intelligence)
- Part 3 stays English only
- Re-applies bold formatting (not copied from English)
- Preserves indices, companies, tickers, figures, emoji

**Inputs:** final.msg1.en.txt, final.msg2.en.txt  
**Outputs:** final.msg1.cn.txt, final.msg2.cn.txt

**Fails if:** Validation fails in Chinese mode

---

### 8. dmb-dispatch 📤

**Role:** Send to advisor groups  
**Triggered:** After approval  
**Does:**
- Sends Message 1 EN → all 3 regions
- Sends Message 1 CN → all 3 regions
- Sends Message 2 EN → all 3 regions
- Sends Message 2 CN → all 3 regions
- Sends Message 3 (Part 3) EN → all 3 regions
- Writes receipt per group per message
- Idempotent on retry (checks receipt before re-sending)

**Inputs:** approved decision.json, final.msg*.txt  
**Outputs:** receipts.jsonl, audit id

**Fails if:** Group not connected → alerts working group, stops all groups

---

### 9. dmb-market-brew ☕📊 (Optional)

**Role:** Market intelligence aggregation  
**Purpose:** Monitor WhatsApp groups, scrape web sources, highlight signals  
**Triggered:** Optional daily briefing or scheduled

**Does:**
- Monitors configured WhatsApp groups
- Scrapes websites via Firecrawl
- Keyword-based filtering
- Sentiment analysis
- Deduplication

**Inputs:** Group IDs, API credentials, scraping targets  
**Outputs:** Market signals, briefing

**Note:** This skill is **optional** and separate from the core DMB pipeline.

---

## Troubleshooting

### "Orchestrator failed"

1. Check `state/drafts/<date>/run.json` for `stage` and error
2. View logs: `openclaw dmb-orchestrator --logs --date <date>`
3. Manual fix by stage:
   - **drafting stage:** Run `dmb-draft --date <date>`
   - **awaiting_figures stage:** Wait for or manually run `dmb-market-data --date <date>`
   - **ready_for_review stage:** Check working group for command

### "Draft validation failed"

Run `dmb-validate` manually to see exact failures:
```bash
openclaw dmb-validate --draft state/drafts/<date>/draft.json --lang en
```

### "Bloomberg email not found by 07:55"

1. Check Gmail account has email
2. Check email subject matches pattern `[YYMMDD]_Morning Brew Data`
3. Check Gmail credentials in config
4. Manually run: `openclaw dmb-market-data --date <date>`

### "Dispatch failed to one region"

1. Check WhatsApp connection for that region
2. Retry dispatch for failed messages (idempotent):
   ```bash
   openclaw dmb-dispatch --date <date> --region MY
   ```

### "Translator failed"

Check Chinese validation:
```bash
openclaw dmb-validate --draft state/drafts/<date>/final.msg1.cn.txt --lang cn
```

---

## Development & Extension

### Adding a new data source

1. Create new skill in `skills/dmb-newsource/SKILL.md`
2. Reference in `dmb-orchestrator` sequence (step X)
3. Write output to `state/drafts/<date>/sources/`
4. Add to `dmb-draft` input sources

### Changing editorial rules

1. Update `references/editorial-rules.md`
2. Update validation checks in `dmb-validate` script
3. Test against recent drafts
4. Document change in CHANGELOG

### Adding a new language

1. Duplicate `dmb-translate` → `dmb-translate-{lang}`
2. Configure language in SKILL.md
3. Add language code to approval command (APPROVE LANG es)
4. Update dispatch to handle new message variants

---

## Support & Escalation

| Issue | First Check | Escalation |
|-------|-------------|-----------|
| Daily run didn't complete | Check run.json stage | View logs, check API status |
| Supervisor commands not working | Is sender on approver allowlist? | Check config, add E.164 |
| Bloomberg figures don't match draft | Check reconciliation.jsonl | Manual adjudication, mark override |
| Translation quality poor | Compare EN vs CN in side-by-side | Review specific translation, rework |
| Dispatch to one region failed | Check WhatsApp connection | Manual retry or skip region |

---

## Monitoring & Analytics

Track system health:

```bash
# Success rate (last 7 days)
openclaw dmb-orchestrator --stats --since 7d

# Failed runs
openclaw dmb-orchestrator --list --status failed --since 30d

# Average pipeline duration
openclaw dmb-orchestrator --metrics --since 7d

# Approval times (how long supervisors take)
openclaw dmb-review-gate --metrics --since 30d

# Dispatch success by region
openclaw dmb-dispatch --metrics --since 7d
```

---

## Files Included

### Skills (in `skills/`)
- `dmb-orchestrator/SKILL.md`
- `dmb-macro-events/SKILL.md` + scripts/
- `dmb-draft/SKILL.md` + references/
- `dmb-market-data/SKILL.md` + scripts/
- `dmb-validate/SKILL.md` + scripts/
- `dmb-review-gate/SKILL.md`
- `dmb-translate/SKILL.md`
- `dmb-dispatch/SKILL.md` + scripts/

### References (in `skills/dmb-draft/references/`)
- `format-spec.md` (canonical output templates)
- `editorial-rules.md` (writing guidelines)

### Config (in `config/`)
- `te_calendar.env.example` (TradingEconomics)
- `holidays.example.yaml` (market closures)
- `dmb-dispatch.json.example` (advisor groups)

### Scripts (in `scripts/`)
- `validate.py` (validation engine)
- `parse_bloomberg_email.py` (Bloomberg parsing)
- `te_calendar.py` (TradingEconomics sync)
- `dispatch.sh` (WhatsApp send)
- `setup-dmb.sh` (initial setup wizard)

---

## Deployment Checklist

Before going live:

- [ ] All 8 core skills installed
- [ ] TradingEconomics API key configured
- [ ] Bloomberg Gmail account set up
- [ ] WhatsApp Business API credentials
- [ ] Advisor group IDs in config
- [ ] Approver E.164 numbers in allowlist
- [ ] Market holidays for 2026 loaded
- [ ] Editorial references reviewed by desk
- [ ] Test run on past date passes validation
- [ ] Supervisor commands tested in working group
- [ ] Chinese translation reviewed by native speaker
- [ ] Dispatch to all 3 regions tested
- [ ] Cron scheduled (05:00 UTC weekdays)
- [ ] Monitoring dashboard set up
- [ ] Error notification emails configured

---

## Version History

**v1.0 (2026-07-31)** — Initial release
- 8 core skills + optional dmb-market-brew
- Full pipeline from events → draft → approval → dispatch
- Chinese translation
- Deterministic validation
- Supervisor approval commands

---

## Contact & Support

- **Questions:** [Team email]
- **Issues:** File in [Jira/GitHub]
- **On-call:** [Slack #dmb-oncall]
- **Docs:** [Internal wiki]

---

**Ready to deploy?**

```bash
./scripts/setup-dmb.sh
openclaw dmb-orchestrator --test --date 2026-07-31
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"
```

All 9 skills working as one system. ✨
