# DMB Agent System — Export & Installation Guide

**For:** Team members installing the iFAST Daily Market Brew system  
**Time:** 45 minutes (install + test)  
**Difficulty:** Beginner-friendly

---

## 🚀 What to Export to Your Team

### Files to Export (Copy these folders/files)

```
dmb-agent/
├── README.md                    ← START HERE
├── QUICK_START.md              ← This file (step-by-step install)
├── SUPERVISOR_GUIDE.md         ← For research team only
├── ADMIN_CHECKLIST.md          ← For ops/admin only
│
├── skills/                      ← All 9 skills
│   ├── dmb-orchestrator/
│   ├── dmb-macro-events/
│   ├── dmb-draft/
│   ├── dmb-market-data/
│   ├── dmb-validate/
│   ├── dmb-review-gate/
│   ├── dmb-translate/
│   └── dmb-dispatch/
│
├── config/                      ← Configuration templates
│   ├── te_calendar.env.example
│   ├── holidays.example.yaml
│   └── dmb-dispatch.json.example
│
├── scripts/                     ← Setup & test scripts
│   ├── setup-dmb.sh
│   └── test-dmb.sh
│
└── state/                       ← Create empty directories
    ├── drafts/
    ├── events/
    ├── marketdata/
    └── holidays/
```

---

## 📋 Export Checklist (Do This Once)

Before exporting to team:

- [ ] Review `DMB_AGENT_SETUP.md` (you have it locally)
- [ ] Review `DMB_DISTRIBUTION_GUIDE.md` (you have it locally)
- [ ] Gather all credentials:
  - [ ] TradingEconomics API key
  - [ ] Bloomberg Gmail account + password
  - [ ] WhatsApp Business API credentials
  - [ ] Advisor group IDs (3 regions)
  - [ ] Supervisor phone numbers (E.164 format)
- [ ] Test on past date yourself (to verify credentials work)
- [ ] Create config/ folder with example files
- [ ] Prepare email/Slack announcement
- [ ] Create scripts/setup-dmb.sh (see template below)

---

## 📦 How to Export (Git Method - Recommended)

### Step 1: Create Git Repository

```bash
# Create repo folder
mkdir dmb-agent
cd dmb-agent/

# Initialize git
git init

# Copy skills
cp -r /path/to/your/dmb/skills ./

# Copy config examples
mkdir -p config/
cp your_te_calendar.env config/te_calendar.env.example
cp your_holidays.yaml config/holidays.example.yaml
cp your_dispatch.json config/dmb-dispatch.json.example

# Create state directories (will be filled by system)
mkdir -p state/{drafts,events,marketdata,holidays}

# Create setup script (see template below)
mkdir -p scripts/
cp setup-dmb.sh scripts/

# Create documentation
cat > README.md << 'EOF'
# iFAST Daily Market Brew Agent

Automated daily market briefings with supervisor approval, Chinese translation, 
and dispatch to advisor groups in Malaysia, Singapore, and Hong Kong.

## Quick Start

1. Read: QUICK_START.md
2. Run: bash scripts/setup-dmb.sh
3. Done!

## Roles

- **Supervisors:** See SUPERVISOR_GUIDE.md
- **Operations:** See ADMIN_CHECKLIST.md
- **Full docs:** See documentation in repo root
EOF

# Commit
git add .
git commit -m "Initial: DMB Agent system v1.0"
git remote add origin https://github.com/yourteam/dmb-agent.git
git push -u origin main
```

**Share with team:** `https://github.com/yourteam/dmb-agent.git`

---

## 📥 Step-by-Step Installation for Team Members

### For Everyone

**Prerequisites (check before starting):**
```bash
# Must have these installed
openclaw --version              # OpenClaw CLI
python3 --version               # Python 3.8+
git --version                   # Git

# If any missing:
# - Install OpenClaw: https://openclaw.dev/install
# - Install Python: https://python.org
# - Install Git: https://git-scm.com
```

---

### Installation Steps (Same for All Roles)

#### Step 1: Clone Repository (5 minutes)

```bash
# Clone the repo
git clone https://github.com/yourteam/dmb-agent.git
cd dmb-agent/

# Verify folder structure
ls -la
# Should see: config/, scripts/, skills/, state/, README.md, QUICK_START.md
```

#### Step 2: Install All Skills (10 minutes)

```bash
# Install each skill
openclaw install skills/dmb-orchestrator
openclaw install skills/dmb-macro-events
openclaw install skills/dmb-draft
openclaw install skills/dmb-market-data
openclaw install skills/dmb-validate
openclaw install skills/dmb-review-gate
openclaw install skills/dmb-translate
openclaw install skills/dmb-dispatch

# Verify installations
openclaw skills list | grep dmb-
# Should list all 8 dmb-* skills
```

#### Step 3: Configure Credentials (10 minutes)

```bash
# Copy environment template
cp config/te_calendar.env.example .env

# Edit with YOUR credentials
nano .env
# Add:
# - TRADING_ECONOMICS_API_KEY=your_key
# - GMAIL_USERNAME=your_email@gmail.com
# - GMAIL_PASSWORD=your_app_password
# - WHATSAPP_API_TOKEN=your_token
# - WHATSAPP_PHONE_ID=your_phone_id
```

**Get each credential:**

| Credential | Where | How |
|------------|-------|-----|
| **TradingEconomics API Key** | [tradingeconomics.com/api](https://tradingeconomics.com/api) | Free tier available |
| **Gmail for Bloomberg** | Gmail account | Setup app password (2FA required) |
| **WhatsApp API** | [business.facebook.com](https://business.facebook.com) | Already set up by admin |

#### Step 4: Configure System (5 minutes)

```bash
# Copy dispatch config
cp config/dmb-dispatch.json.example config/dmb-dispatch.json

# Edit with your advisor groups
nano config/dmb-dispatch.json
# Update:
# - Group IDs (MY, SG, HK)
# - Approver phone numbers in E.164 format (+60xxxxxxxxx)

# Copy holidays
cp config/holidays.example.yaml state/holidays/2026.yaml

# Verify it looks right
cat state/holidays/2026.yaml
```

#### Step 5: Run Automated Setup (5 minutes)

```bash
# Make setup script executable
chmod +x scripts/setup-dmb.sh

# Run setup (creates state folders, validates config)
bash scripts/setup-dmb.sh

# Output should show:
# ✓ All skills installed
# ✓ Credentials valid
# ✓ State folders created
```

#### Step 6: Test System (10 minutes)

```bash
# Test on a past date (8+ days ago)
# Example: if today is 2026-07-31, test with 2026-07-20

openclaw dmb-orchestrator --test --date 2026-07-20

# Watch the output:
# [1/5] Refreshing events...
# [2/5] Drafting brief...
# [3/5] Validating...
# [4/5] Processing market data...
# [5/5] Complete!

# Check output
cat state/drafts/2026-07-20/draft.json | jq '.headline'
# Should see a headline about markets

# If test passes:
echo "✓ Setup successful!"
```

**If test fails:**
```bash
# Check logs
openclaw dmb-orchestrator --logs --date 2026-07-20

# Common issues:
# - "API key invalid" → Check credentials in .env
# - "Group not found" → Check dmb-dispatch.json
# - "Email not found" → Check Gmail setup
```

#### Step 7: Verify Installation (5 minutes)

```bash
# List all installed skills
openclaw skills list | grep dmb-

# Check config is correct
echo "TradingEconomics API: $(grep TE_API_KEY .env)"
echo "Dispatch groups: $(grep -c '@g.us' config/dmb-dispatch.json)"

# All should show ✓
```

---

## ✅ Verification Checklist

After installation, verify each item:

```
INSTALLATION VERIFICATION

Skills:
  ☐ dmb-orchestrator installed (openclaw skills list)
  ☐ dmb-macro-events installed
  ☐ dmb-draft installed
  ☐ dmb-market-data installed
  ☐ dmb-validate installed
  ☐ dmb-review-gate installed
  ☐ dmb-translate installed
  ☐ dmb-dispatch installed

Configuration:
  ☐ .env file has TradingEconomics API key
  ☐ .env file has Gmail credentials
  ☐ .env file has WhatsApp credentials
  ☐ config/dmb-dispatch.json has 3 group IDs
  ☐ config/dmb-dispatch.json has supervisor E.164s
  ☐ state/holidays/2026.yaml loaded

Testing:
  ☐ Test run completed without errors
  ☐ Draft JSON created
  ☐ All validation rules passed
  ☐ No "FAILED" messages

Ready to Deploy:
  ☐ All above verified
  ☐ Can proceed to production scheduling
```

---

## 🎯 Role-Specific: After Installation

### For Supervisors (Research Team)

**Done installing? Now read:**

```bash
cat SUPERVISOR_GUIDE.md
```

**You now have access to:**
- APPROVE — Accept the day's brief
- EDIT — Modify headline, bullets, or items
- REJECT — Stop the day if something's wrong
- STATUS — Check current progress

**That's it!** You only need to approve/edit daily in WhatsApp.

---

### For Admins (Operations/DevOps)

**Done installing? Now read:**

```bash
cat ADMIN_CHECKLIST.md
```

**Your next steps:**
1. Schedule cron job for daily run
2. Set up monitoring and alerts
3. Create on-call documentation
4. Test end-to-end on live date

```bash
# Schedule daily run (05:00 UTC, Monday-Friday)
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"

# Verify scheduled
openclaw dmb-orchestrator --list-scheduled
```

---

## 🚨 Troubleshooting

### "Skill not found"

```bash
# Problem: Skill not installed
# Solution:
openclaw install skills/dmb-orchestrator
openclaw skills list | grep dmb-orchestrator
```

### "API key invalid"

```bash
# Problem: TradingEconomics API key doesn't work
# Solution:
# 1. Check .env file:
cat .env | grep TE_API_KEY

# 2. Regenerate key at https://tradingeconomics.com/api/keys
# 3. Update .env
# 4. Test again
```

### "Group ID not found"

```bash
# Problem: WhatsApp group ID incorrect
# Solution:
# 1. In WhatsApp group, go to Group Info
# 2. Copy the full JID (format: 123456789-1234567890@g.us)
# 3. Update config/dmb-dispatch.json
# 4. Test again
```

### "Gmail authentication failed"

```bash
# Problem: Gmail password not working
# Solution:
# 1. Enable 2FA on Gmail account
# 2. Create app password (https://myaccount.google.com/apppasswords)
# 3. Use app password in .env (not your regular password)
# 4. Test again
```

---

## 📞 Support

**If something doesn't work:**

1. **Check logs:**
   ```bash
   openclaw dmb-orchestrator --logs --follow
   ```

2. **Test specific skill:**
   ```bash
   openclaw dmb-draft --date 2026-07-20
   openclaw dmb-validate --draft state/drafts/2026-07-20/draft.json
   ```

3. **Post in Slack:** `#dmb-support` with error message

4. **Contact admin:** [email] or `@oncall`

---

## ⏭️ Next Steps After Installation

### Day 1-2: Verify Everything Works
```bash
# Run test again
openclaw dmb-orchestrator --test --date 2026-07-20

# Check today's status (if past 08:05 MYT)
openclaw dmb-orchestrator --status --date $(date +%Y-%m-%d)
```

### Day 3: Review First Real Brief
```bash
# Once today's draft is posted, review it in WhatsApp working group
# Check: headlines make sense, numbers are correct, 5 proposed items sound good
```

### Day 4: First Approval
```bash
# Supervisors: Give your first APPROVE or EDIT command in WhatsApp
# Watch the system translate and dispatch in real-time
```

### Week 1: Monitor Daily
```bash
# Admin: Watch for errors
openclaw dmb-orchestrator --logs --since 1h

# Supervisor: Approve/edit each day
# Review briefing quality
# Give feedback
```

---

## 📊 Full Command Reference

```bash
# Monitor & Troubleshoot
openclaw dmb-orchestrator --status --date 2026-07-31
openclaw dmb-orchestrator --logs --follow
openclaw dmb-orchestrator --logs --since 1h

# Test & Debug
openclaw dmb-orchestrator --test --date 2026-07-20
openclaw dmb-draft --date 2026-07-20
openclaw dmb-validate --draft state/drafts/2026-07-20/draft.json

# Manual Operations
openclaw dmb-orchestrator --run --now
openclaw dmb-macro-events refresh --target 2026-07-31
openclaw dmb-translate --date 2026-07-31
openclaw dmb-dispatch --date 2026-07-31

# List & Schedule
openclaw dmb-orchestrator --list-scheduled
openclaw dmb-orchestrator --schedule "0 5 * * 1-5"
openclaw skills list | grep dmb-
```

---

## ✨ Success Indicators

You'll know it's working when you see:

✓ Test run completes without errors  
✓ Draft JSON created with headline, bullets, 15 items  
✓ Validation passes all checks  
✓ Brief appears in WhatsApp working group daily  
✓ Supervisors can approve/edit via WhatsApp commands  
✓ Brief translates to Chinese automatically  
✓ Briefs dispatch to all 3 advisor regions  
✓ Receipts show successful sends  

---

## 🎯 Duration Summary

| Task | Time |
|------|------|
| Prerequisites check | 5 min |
| Clone repo | 5 min |
| Install 8 skills | 10 min |
| Configure credentials | 10 min |
| Configure system | 5 min |
| Run automated setup | 5 min |
| Test system | 10 min |
| **Total** | **50 min** |

---

## 🚀 You're Ready!

Once you see ✓ on all verification items, you're set to go live.

**Questions?** Post in `#dmb-support` or contact your admin.

**First approval?** See SUPERVISOR_GUIDE.md for command examples.

**Ready to extend?** See documentation in repo root for architecture details.

---

**Installation Version:** 1.0  
**Last Updated:** 2026-07-31  
**Support:** [Your Team Slack #channel]
