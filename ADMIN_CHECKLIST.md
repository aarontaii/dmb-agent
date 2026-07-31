# Daily Market Brew — Admin Deployment Guide

## Installation (30-45 min)

### Step 1: Prerequisites

```bash
# Check OpenClaw
openclaw --version

# Check Python
python3 --version  # Must be 3.8+

# Clone repo
git clone https://github.com/yourteam/dmb-agent.git
cd dmb-agent/
```

### Step 2: Install Skills

```bash
# Install all 8 core skills
openclaw install skills/dmb-orchestrator
openclaw install skills/dmb-macro-events
openclaw install skills/dmb-draft
openclaw install skills/dmb-market-data
openclaw install skills/dmb-validate
openclaw install skills/dmb-review-gate
openclaw install skills/dmb-translate
openclaw install skills/dmb-dispatch
```

### Step 3: Configure

```bash
# Copy example configs
cp config/te_calendar.env.example .env
cp config/dmb-dispatch.json.example config/dmb-dispatch.json

# Edit with real values
nano .env                              # TradingEconomics API key
nano config/dmb-dispatch.json          # WhatsApp group IDs and approvers
nano state/holidays/2026.yaml          # Market closures
```

### Step 4: Test

```bash
# Test on a past date (8+ days ago to use fresh data)
openclaw dmb-orchestrator --test --date 2026-07-28

# Check output
cat state/drafts/2026-07-28/draft.json | jq
```

### Step 5: Schedule

```bash
# Daily cron: Monday-Friday, 05:00 UTC (08:00 MYT)
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"

# Verify scheduled
openclaw dmb-orchestrator --list-scheduled
```

---

## Monitoring

### Daily Checks

```bash
# Is today's run complete?
openclaw dmb-orchestrator --status --date $(date +%Y-%m-%d)

# Any errors?
openclaw dmb-orchestrator --logs --since 1h

# Did dispatch go out?
cat state/drafts/$(date +%Y-%m-%d)/receipts.jsonl
```

### Weekly Metrics

```bash
# Success rate
openclaw dmb-orchestrator --stats --since 7d

# Failed runs
openclaw dmb-orchestrator --list --status failed --since 7d
```

---

## Troubleshooting

### Run stuck at "awaiting_figures"

- Bloomberg email not arrived by 07:55 MYT
- Check Gmail account
- Manually trigger: `openclaw dmb-market-data --date $(date +%Y-%m-%d)`

### Dispatch failed to one region

- Check WhatsApp Business API status
- Retry idempotently: `openclaw dmb-dispatch --date $(date +%Y-%m-%d) --region MY`

### Validation failed

- Check specific failures: `openclaw dmb-validate --draft state/drafts/$(date +%Y-%m-%d)/draft.json`
- Common: word count, index order, tier distribution

---

## Escalation

| Issue | Check First | Fix |
|-------|-------------|-----|
| Run didn't start | Cron scheduled? | `openclaw dmb-orchestrator --schedule ...` |
| Draft is blank | Web search down? | Try again in 5 min |
| Bloomberg data missing | Email arrived? | Check Gmail account |
| Dispatch failed | WhatsApp connected? | Check API status |
| Supervisor can't approve | Not on allowlist? | Add E.164 to config |

---

## Deployment Checklist (for new team)

- [ ] All 8 skills installed
- [ ] TradingEconomics API key working
- [ ] Bloomberg Gmail account accessible
- [ ] WhatsApp Business API credentials set
- [ ] Advisor group IDs in config
- [ ] Supervisor E.164 numbers in allowlist
- [ ] Test run passes validation
- [ ] Dispatch works to all 3 regions
- [ ] Cron scheduled (05:00 UTC, weekdays)
- [ ] Error notifications configured
- [ ] On-call documentation updated
