# DMB Agent Distribution Guide

**For:** Sharing the iFAST Daily Market Brew system with team members  
**Format:** Setup instructions, deployment methods, support structures  
**Status:** Production ready

---

## What You're Distributing

A complete, coordinated **8-skill system** (+ 1 optional) that produces:

```
iFAST Daily Market Brew
├─ Message 1: Market Moves (English & Chinese)
├─ Message 2: 5 Intelligence Items + Key Takeaways (English & Chinese)
└─ Message 3: Yields & FX Rates (English only)

Delivery: WhatsApp → 3 regions (MY, SG, HK) daily
Automation: 95% (only approval gate is manual)
Time to complete: 08:00-12:00 MYT (4 hours including wait for Bloomberg email)
```

---

## Distribution Audience

### 1. Research Team Members (Supervisors)
**What they do:** Approve/edit drafts in WhatsApp group  
**Setup:** 5 minutes (just add E.164 to allowlist)  
**Document:** Give them `DMB_SUPERVISOR_GUIDE.md` (see below)

### 2. Operations/DevOps (System Admins)
**What they do:** Deploy, monitor, troubleshoot system  
**Setup:** 30-45 minutes (install skills, set up cron, test)  
**Document:** Give them `DMB_AGENT_SETUP.md` + deployment checklist

### 3. Developers (Extensions)
**What they do:** Extend rules, add data sources, fix issues  
**Setup:** 1 hour (read all specs, understand state structure)  
**Document:** Give them all skill files + references/

---

## Quick Distribution Checklist

### Pre-Distribution (do this once)

- [ ] Review all 8 skill definitions (SKILL.md files)
- [ ] Verify editorial rules are approved by desk (`editorial-rules.md`)
- [ ] Verify output format is correct (`format-spec.md`)
- [ ] Test entire pipeline on a past date (07-28 or earlier)
- [ ] Confirm TradingEconomics API key works
- [ ] Confirm Bloomberg email account access
- [ ] Confirm WhatsApp Business API credentials
- [ ] List the 3 advisor group IDs and approver phone numbers
- [ ] Create `/config` folder with examples
- [ ] Create `/state` folder structure (drafts, events, marketdata, holidays)

### Distribution (per recipient)

- [ ] Send appropriate docs based on role (see below)
- [ ] Share `DMB_AGENT_SETUP.md` (comprehensive reference)
- [ ] Send credentials separately (never in docs):
  - TradingEconomics API key
  - Bloomberg Gmail password
  - WhatsApp Business credentials
- [ ] Add supervisor E.164 to approver allowlist
- [ ] Schedule team walkthrough (30 min)

---

## Distribution Methods

### Method 1: Git Repository (Recommended)

**For:** Clean version control, easy updates, collaboration

```bash
# Set up repo
git init dmb-agent
cd dmb-agent/

# Copy files
cp -r /home/openclaw/.openclaw/workspace-dmb/skills ./
cp /home/openclaw/.openclaw/workspace-dmb/DMB_AGENT_SETUP.md ./
cp /home/openclaw/.openclaw/workspace-dmb/DMB_DISTRIBUTION_GUIDE.md ./

# Create config examples
mkdir -p config/
cp [your TradingEconomics config] config/te_calendar.env.example
cp [your holidays] config/holidays.example.yaml
cp [your dispatch config] config/dmb-dispatch.json.example

# Create deployment scripts
mkdir -p scripts/
# Copy or create setup-dmb.sh, test-dmb.sh, etc.

# Version and push
git add .
git commit -m "Initial: DMB Agent system v1.0"
git tag v1.0
git remote add origin [your-repo]
git push -u origin main
```

**Installation for others:**

```bash
git clone https://github.com/yourteam/dmb-agent.git
cd dmb-agent/
./scripts/setup-dmb.sh
```

---

### Method 2: Direct Archive

**For:** Email/Slack sharing, no git needed

```bash
# Create archive
tar -czf dmb-agent-v1.0.tar.gz \
  skills/ \
  config/ \
  scripts/ \
  DMB_AGENT_SETUP.md \
  DMB_DISTRIBUTION_GUIDE.md \
  README.md

# Share via Slack, email, or Drive
```

**Installation for others:**

```bash
tar -xzf dmb-agent-v1.0.tar.gz
cd dmb-agent/
bash scripts/setup-dmb.sh
```

---

### Method 3: OpenClaw Skill Registry

**For:** Organization-wide discovery

```bash
# Register each skill
for skill in skills/dmb-*/; do
  openclaw publish "$skill" --registry org --version 1.0
done

# Others install with:
openclaw install dmb-orchestrator@1.0
openclaw install dmb-macro-events@1.0
# ... etc
```

---

## Documentation by Role

### For Supervisors (Research Team)

**Create file:** `DMB_SUPERVISOR_GUIDE.md`

```markdown
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

*When to use:* Proposed 5 is good as-is

**Example:** `APPROVE`

### APPROVE PICK 2,5,7,9,13
Override the proposed 5 with your custom 5.
The system validates that your picks maintain tier distribution.

*When to use:* You want different items than proposed

**Example:** `APPROVE PICK 1,3,8,11,14`

### APPROVE EVENTS 1,2,3
Choose which Events Ahead day-groups to include.
Leave blank to drop Events Ahead section entirely.

*When to use:* Some events are less important today

**Example:** `APPROVE EVENTS 1,2`

### EDIT HEADLINE <new text>
Replace the headline (max 15 words).

**Example:** `EDIT HEADLINE Asia Rallies on China Stimulus; Fed Awaits Data`

### EDIT BULLET <n> <text>
Replace one of the 6 wrap bullets (max 40 words).

**Example:** `EDIT BULLET 3 Nikkei 225 rose 2.1%, reversing last week's weakness.`

### EDIT <n> <text>
Replace one of the 15 candidate items (25-40 words, entity-first).

**Example:** `EDIT 7 Samsung Electronics beat Q2 earnings forecast, guiding higher for memory chip demand.`

### REJECT <reason>
Stop the day. The desk falls back to manual.

**Example:** `REJECT Data looks stale on FX moves`

### STATUS
Show current stage and outstanding items.

### HOLD <minutes>
Delay dispatch by N minutes (e.g., `HOLD 30`).

## Timeline

- **08:05 UTC (08:05 MYT):** Draft posted to working group
- **~07:55 MYT:** Bloomberg email arrives (Part 3 data)
- **~12:00 MYT:** Bloomberg figures reconciled, ready for final approval
- **By 12:15 MYT:** You give final approval
- **12:20 MYT:** Dispatches to advisor groups

## Quick Tips

- **The numbers matter.** Every figure comes from Bloomberg or Reuters. We don't invent data.
- **Edit with care.** Editing changes the hash and requires re-validation.
- **Check the sources.** All 5 items must come from Reuters, Bloomberg, CNBC, or FT.
- **Trust the validator.** If the system says something fails, fix it — the validator doesn't hallucinate.

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
```

---

### For Admins (Operations/DevOps)

**Create file:** `DMB_ADMIN_GUIDE.md`

```markdown
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
for skill in skills/dmb-orchestrator dmb-macro-events dmb-draft dmb-market-data dmb-validate dmb-review-gate dmb-translate dmb-dispatch; do
  openclaw install "skills/$skill"
done
```

### Step 3: Configure

```bash
# Copy example configs
cp config/te_calendar.env.example .env
cp config/holidays.example.yaml state/holidays/2026.yaml
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
cat state/drafts/2026-07-28/review-pack.txt
```

### Step 5: Schedule

```bash
# Daily cron: Monday-Friday, 05:00 UTC (08:00 MYT)
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"

# Verify scheduled
openclaw dmb-orchestrator --list-scheduled
```

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

### Troubleshooting

**Run stuck at "awaiting_figures":**
- Bloomberg email not arrived by 07:55 MYT
- Check Gmail account
- Manually trigger: `openclaw dmb-market-data --date $(date +%Y-%m-%d)`

**Dispatch failed to one region:**
- Check WhatsApp Business API status
- Retry idempotently: `openclaw dmb-dispatch --date $(date +%Y-%m-%d) --region MY`

**Validation failed:**
- Check specific failures: `openclaw dmb-validate --draft state/drafts/$(date +%Y-%m-%d)/draft.json`
- Common: word count, index order, tier distribution

## Escalation

| Issue | Check First | Fix |
|-------|-------------|-----|
| Run didn't start | Cron scheduled? | `openclaw dmb-orchestrator --schedule ...` |
| Draft is blank | Web search down? | Try again in 5 min |
| Bloomberg data missing | Email arrived? | Check Gmail account |
| Dispatch failed | WhatsApp connected? | Check API status |
| Supervisor can't approve | Not on allowlist? | Add E.164 to config |

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
```

---

### For Developers (Extensions)

**Create file:** `DMB_DEV_GUIDE.md`

```markdown
# Daily Market Brew — Developer Guide

## Architecture Overview

**9 skills orchestrating a content pipeline:**

1. **dmb-orchestrator** (conductor) → sequences others
2. **dmb-macro-events** (data) → TradingEconomics calendar
3. **dmb-draft** (agent) → writes content
4. **dmb-market-data** (data) → Bloomberg email parsing
5. **dmb-validate** (checker) → rules engine
6. **dmb-review-gate** (gate) → supervisor commands
7. **dmb-translate** (transform) → English to Chinese
8. **dmb-dispatch** (send) → WhatsApp delivery

State machine: drafting → awaiting_figures → ready_for_review → approved → dispatched

## Key Files

```
skills/dmb-*/SKILL.md                  # Skill definitions
skills/dmb-draft/references/
  ├── format-spec.md                   # Output templates (canonical)
  └── editorial-rules.md               # Writing guidelines
scripts/validate.py                    # Validation engine (~20 rules)
state/drafts/<date>/draft.json         # Structured draft
state/events/YYYY-Www.json             # Macro events store
```

## Extending the System

### Adding a new validation rule

1. Open `scripts/validate.py`
2. Add rule function: `def check_new_rule(draft) -> bool`
3. Add to validation run
4. Test against past drafts
5. Document in SKILL.md

### Adding a new editorial rule

1. Update `skills/dmb-draft/references/editorial-rules.md`
2. Implement in dmb-draft SKILL.md
3. Add validation check if needed
4. Update format-spec.md if output changes
5. Test with draft generation

### Adding a new data source

1. Create `skills/dmb-source-x/SKILL.md`
2. Add step to `dmb-orchestrator` sequence
3. Write output to `state/drafts/<date>/sources/`
4. Add to `dmb-draft` input search list

## Testing

```bash
# Test specific skill in isolation
openclaw dmb-draft --date 2026-07-28

# Test validation
openclaw dmb-validate --draft state/drafts/2026-07-28/draft.json

# Test full pipeline
openclaw dmb-orchestrator --test --date 2026-07-28

# Test Chinese translation quality
openclaw dmb-translate --date 2026-07-28 --validate

# Compare output against canonical
diff -u expected.txt state/drafts/2026-07-28/draft.json
```

## Common Bugs

- **Index order wrong:** Check format-spec.md, indices must be in exact order
- **Word count fails:** Count carefully — includes emojis, counts hyphens as part of word
- **Tier distribution cap fails:** Check dmb-draft logic, distribution must be >=3 corporate in T2
- **Bloomberg reconciliation fails:** Check sanity bands, verify figures against Bloomberg directly

---

## Contributing

1. Create a feature branch: `git checkout -b feat/your-feature`
2. Make changes
3. Test thoroughly: `./scripts/test-dmb.sh`
4. Document changes
5. Create PR with test results
6. Merge and tag: `git tag v1.1`

---
```

---

## Communication Templates

### Announcement Email

```
Subject: Launch: iFAST Daily Market Brew automation

Hi team,

We're rolling out the automated Daily Market Brew system. This replaces the manual
research process with a coordinated 8-skill pipeline that produces daily briefings
to advisor groups.

WHAT'S CHANGING
• Instead of manual drafting, we use a system that writes daily briefs automatically
• You approve/edit in the WhatsApp group (easy commands, 2-minute job)
• Bloomberg data auto-reconciles (no more copy-paste)
• Part 3 translates to Chinese automatically
• Dispatch is automatic (one-click send, idempotent)

YOUR ROLE
If you're a supervisor: Give approval commands in the working group
If you're ops: Deploy and monitor the system
If you're a developer: Extend or fix as needed

WHAT YOU NEED TO DO
1. Read: DMB_SUPERVISOR_GUIDE.md (5 min) OR DMB_ADMIN_GUIDE.md (20 min)
2. Install: Run setup-dmb.sh (ops team only)
3. Test: We'll do a live demo on [Date]
4. Go live: First automated run [Date]

Q: What if something breaks?
A: It's designed to fail loudly. If dispatch fails to one region, we keep the others
   and alert you. We never send partial or corrupted content.

Q: Do we still have manual control?
A: 100%. The supervisor commands (APPROVE, EDIT, REJECT) give you veto power over everything.

More details: See DMB_AGENT_SETUP.md

Let's talk about this on [Slack #channel]

[Your name]
```

### Slack Channel Announcement

```
🚀 DMB Agent System Live

We're automating the Daily Market Brew pipeline! 

📋 What to do:
• Supervisors: Read DMB_SUPERVISOR_GUIDE.md
• Ops: Read DMB_ADMIN_GUIDE.md
• Devs: Read DMB_DEV_GUIDE.md

🎯 First automated run: [Date]
📞 Questions: Drop them here
🆘 Issues: Post in #dmb-issues

Your approval commands are still the gate — nothing goes to advisors without you.
```

---

## Rollout Timeline

### Week 1: Deploy & Test

- Day 1-2: Install system, configure, test
- Day 3-4: Run on archived dates, verify output
- Day 5: Dry run (post to working group, don't dispatch)

### Week 2: Soft Launch

- Day 1: First live run, manual dispatch approval
- Day 2-5: Daily runs with supervisor approval

### Week 3: Full Automation

- All functions automated
- Monitoring in place
- On-call documentation done

---

## Support Structure

### Slack Channels

- `#dmb-system` — Announcements and updates
- `#dmb-questions` — Questions about the system
- `#dmb-issues` — Bug reports and escalation
- `#dmb-oncall` — On-call support rotation

### Documentation

- `DMB_AGENT_SETUP.md` — Reference docs
- `DMB_SUPERVISOR_GUIDE.md` — For approvers
- `DMB_ADMIN_GUIDE.md` — For ops
- `DMB_DEV_GUIDE.md` — For developers
- SKILL.md files — Detailed skill definitions
- `references/` — Editorial rules and format

### Escalation

**Level 1:** Post in #dmb-questions  
**Level 2:** Escalate to #dmb-oncall if urgent  
**Level 3:** Page on-call engineer for production issues

---

## Deployment Checklist (Complete)

- [ ] Repository set up (GitHub/Git)
- [ ] All 9 skills reviewed and understood
- [ ] Credentials collected (TE API, Bloomberg, WhatsApp)
- [ ] Config files created from examples
- [ ] State directories initialized
- [ ] Skills installed locally
- [ ] Test run on past date passes validation
- [ ] Test translation quality (Chinese native speaker review)
- [ ] Test dispatch to all 3 regions
- [ ] Cron scheduled (05:00 UTC, weekdays)
- [ ] Monitoring/alerting configured
- [ ] Supervisor E.164s added to allowlist
- [ ] Documentation created (role-specific)
- [ ] Communication templates sent
- [ ] Team walkthrough scheduled
- [ ] On-call rotation documented
- [ ] Escalation procedures documented

---

**Ready to launch?** Use the checklists above and the role-specific guides to equip your team.

Once live, the system runs unattended Mon-Fri, awaiting only the supervisor approval in WhatsApp. ✨
