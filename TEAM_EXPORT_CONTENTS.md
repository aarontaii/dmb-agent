# DMB Agent Export — What to Send to Your Team

**This file tells you exactly what to copy and how to organize it for your team.**

---

## 📦 Export Package Contents

Copy these files/folders to create the team export:

```
dmb-agent/                              ← Create this folder
├── README.md                           ← Team overview
├── QUICK_START.md                      ← Installation steps (this is EXPORT_AND_INSTALL.md)
├── SUPERVISOR_GUIDE.md                 ← For research team
├── ADMIN_CHECKLIST.md                  ← For ops team
│
├── skills/                             ← Copy entire skills folder
│   ├── dmb-orchestrator/
│   │   └── SKILL.md
│   ├── dmb-macro-events/
│   │   └── SKILL.md
│   ├── dmb-draft/
│   │   ├── SKILL.md
│   │   ├── scripts/                    (if present)
│   │   └── references/
│   │       ├── format-spec.md
│   │       └── editorial-rules.md
│   ├── dmb-market-data/
│   │   └── SKILL.md
│   ├── dmb-validate/
│   │   └── SKILL.md
│   ├── dmb-review-gate/
│   │   └── SKILL.md
│   ├── dmb-translate/
│   │   └── SKILL.md
│   └── dmb-dispatch/
│       └── SKILL.md
│
├── config/                             ← Configuration templates
│   ├── README.md                       ← Explain each config file
│   ├── te_calendar.env.example         ← TradingEconomics template
│   ├── holidays.example.yaml           ← Market holidays template
│   └── dmb-dispatch.json.example       ← WhatsApp dispatch template
│
├── scripts/                            ← Setup & test scripts
│   ├── setup-dmb.sh                    ← Main setup script
│   ├── test-dmb.sh                     ← Test script
│   └── README.md                       ← Script usage guide
│
├── state/                              ← Empty directories (will be filled by system)
│   ├── drafts/                         (empty, will contain daily drafts)
│   ├── events/                         (empty, will contain macro calendar)
│   ├── marketdata/                     (empty, will contain Bloomberg data)
│   └── holidays/                       (empty, will contain holidays file)
│
└── docs/                               ← Full documentation
    ├── DMB_AGENT_SETUP.md              ← Complete technical reference
    ├── DMB_DISTRIBUTION_GUIDE.md       ← Extended guide (optional, for reference)
    └── README_DISTRIBUTION.md          ← Optional, for reference
```

---

## 🔧 How to Create Export Package

### Using Git (Recommended)

```bash
# Create new directory
mkdir dmb-agent
cd dmb-agent/

# Initialize git
git init

# Copy skills (entire folder)
cp -r /path/to/workspace-dmb/skills ./

# Copy config examples
mkdir -p config/
cp /path/to/workspace-dmb/skills/*/config/*.env.example config/ 2>/dev/null || true
# OR manually create these files with YOUR examples

# Copy scripts (if you have setup scripts)
mkdir -p scripts/
# Create setup-dmb.sh (see template below)

# Create state directories (will be populated by system)
mkdir -p state/{drafts,events,marketdata,holidays}

# Copy documentation
cp /path/to/workspace-dmb/EXPORT_AND_INSTALL.md QUICK_START.md
cp /path/to/workspace-dmb/README_DISTRIBUTION.md docs/README_DISTRIBUTION.md
cp /path/to/workspace-dmb/DMB_AGENT_SETUP.md docs/DMB_AGENT_SETUP.md

# Extract role guides from DMB_DISTRIBUTION_GUIDE.md
# (See "Extract Role Guides" section below)

# Create main README
cat > README.md << 'EOF'
# iFAST Daily Market Brew Agent

Automated daily market intelligence system with supervisor approval, Chinese translation,
and dispatch to advisor groups across Malaysia, Singapore, and Hong Kong.

## Quick Start

New to this system? Start here:

1. **Installation (45 min):** Read [QUICK_START.md](QUICK_START.md)
2. **First approval (5 min):** Read [SUPERVISOR_GUIDE.md](SUPERVISOR_GUIDE.md) (if you're a supervisor)
3. **Setup monitoring (30 min):** Read [ADMIN_CHECKLIST.md](ADMIN_CHECKLIST.md) (if you're ops/admin)

## What This System Does

- ✓ Automatically refreshes market data daily (TradingEconomics)
- ✓ Writes daily market brief (headline + 6 wrap bullets)
- ✓ Generates 15 intelligence item candidates
- ✓ Posts to working group for supervisor review
- ✓ Waits for supervisor approval (via WhatsApp commands)
- ✓ Translates English brief to Chinese automatically
- ✓ Dispatches to 3 advisor regions (MY, SG, HK)
- ✓ Logs all activity and maintains audit trail

## 9 Coordinated Skills

| Skill | Purpose |
|-------|---------|
| dmb-orchestrator | Sequences entire pipeline |
| dmb-macro-events | Manages macro calendar |
| dmb-draft | Writes daily brief |
| dmb-market-data | Parses Bloomberg email |
| dmb-validate | Checks all rules |
| dmb-review-gate | Handles approvals |
| dmb-translate | English ↔ Chinese |
| dmb-dispatch | Sends to advisors |

## Roles

**Supervisors (Research Team):**
- Read: SUPERVISOR_GUIDE.md
- Job: Approve/edit daily brief in WhatsApp group
- Time: ~5 minutes per day

**Admins (Operations/DevOps):**
- Read: ADMIN_CHECKLIST.md
- Job: Deploy, configure, monitor system
- Time: 45 min setup, 5 min daily checks

**Developers:**
- Read: docs/DMB_AGENT_SETUP.md
- Job: Extend, fix, improve system
- Time: 1-2 hours to understand architecture

## Installation

```bash
bash scripts/setup-dmb.sh
```

See QUICK_START.md for detailed steps.

## Support

- **Questions:** Post in #dmb-support
- **Issues:** Contact your admin
- **Escalation:** Page on-call engineer

---

**Version:** 1.0  
**Status:** Production Ready  
**Last Updated:** 2026-07-31
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
.env                          # Never commit credentials
.env.local
state/drafts/                 # Daily generated files
state/events/
state/marketdata/
*.log                         # Logs
__pycache__/
.DS_Store
EOF

# Commit
git add .
git commit -m "Initial: DMB Agent system v1.0 - Ready to share"

# Push to your repository
git remote add origin https://github.com/yourteam/dmb-agent.git
git push -u origin main
```

**Share URL:** `https://github.com/yourteam/dmb-agent.git`

---

## 📄 Extract Role Guides

You need to extract 3 guides from `DMB_DISTRIBUTION_GUIDE.md` and save as separate files:

### 1. Create SUPERVISOR_GUIDE.md

Extract the section starting with "## For Supervisors (Research Team)" from DMB_DISTRIBUTION_GUIDE.md and save as `SUPERVISOR_GUIDE.md`:

```markdown
# Daily Market Brew — Supervisor Guide

## Your Role
You approve (or edit, or reject) the day's draft in the WhatsApp working group.

## The Command Options

You have exactly these commands:

### APPROVE
Accept all proposed choices...

[Continue with rest of supervisor section]
```

### 2. Create ADMIN_CHECKLIST.md

Extract the section "## For Admins (Operations/DevOps)" from DMB_DISTRIBUTION_GUIDE.md and save as `ADMIN_CHECKLIST.md`:

```markdown
# Daily Market Brew — Admin Deployment Guide

## Installation (30-45 min)

### Step 1: Prerequisites
...

[Continue with rest of admin section]
```

### 3. Create DEV_GUIDE.md (Optional)

Extract the section "## For Developers (Extensions)" and save as `DEV_GUIDE.md` (optional, only if you have developers).

---

## 🔐 Credentials: What NOT to Include

**NEVER include in the export:**
- ❌ .env file (has passwords)
- ❌ Any API keys or tokens
- ❌ Gmail passwords
- ❌ WhatsApp Business credentials
- ❌ Real group IDs with phone numbers

**DO include:**
- ✅ .env.example (template without values)
- ✅ config/*example files (templates without values)
- ✅ README files explaining what each credential is

---

## 🔑 Credential Sharing (After Export)

After your team clones the repo, they'll need credentials. Share these separately:

### For Each Team Member (Send Securely):

1. **Email (Secure Channel - 1Password, Vault, etc):**

```
TradingEconomics API Key: [your_key_here]
Gmail Account: [your_email@gmail.com]
Gmail App Password: [your_app_password_here]
```

2. **Configuration Files (Secure Dropbox/Drive link):**
   - `.env` file (actual values)
   - `config/dmb-dispatch.json` (with real group IDs)
   - `state/holidays/2026.yaml` (actual holidays)

3. **Instructions:**
```
1. Clone the repo
2. Copy the .env file to root folder
3. Copy config files to config/ folder
4. Copy holidays file to state/holidays/ folder
5. Run: bash scripts/setup-dmb.sh
```

---

## 📋 Files Checklist

Before sharing, verify your export includes:

```
EXPORT CHECKLIST

Root Level:
  ☐ README.md
  ☐ QUICK_START.md (copy of EXPORT_AND_INSTALL.md)
  ☐ SUPERVISOR_GUIDE.md
  ☐ ADMIN_CHECKLIST.md

Folders:
  ☐ skills/ (all 8 skills)
  ☐ config/ (with .example files)
  ☐ scripts/ (setup-dmb.sh, test-dmb.sh)
  ☐ state/ (empty directories)
  ☐ docs/ (reference documentation)

NOT Included (Good!):
  ☐ .env (no actual credentials)
  ☐ No real API keys in any file
  ☐ No real Gmail passwords
  ☐ No real group IDs with phone numbers

Git Setup:
  ☐ .git folder initialized
  ☐ .gitignore configured
  ☐ Initial commit made
  ☐ Pushed to GitHub/GitLab
```

---

## 📤 Share with Team

### Method 1: GitHub (Recommended)

```bash
# Share this URL with your team:
https://github.com/yourteam/dmb-agent.git

# With instructions:
git clone https://github.com/yourteam/dmb-agent.git
cd dmb-agent/
bash scripts/setup-dmb.sh
```

### Method 2: Zip Archive

```bash
# Create zip file
zip -r dmb-agent-v1.0.zip dmb-agent/

# Share via email/Slack
# Team extracts: unzip dmb-agent-v1.0.zip
#               cd dmb-agent/
#               bash scripts/setup-dmb.sh
```

### Method 3: Drive/Dropbox

```bash
# Upload to shared folder
# Share link with team
# They download and unzip
```

---

## 📧 Announcement Email Template

When you export and share:

```
Subject: Installation Ready - iFAST Daily Market Brew System

Hi team,

The DMB Agent system is ready to install! Here's how to get started:

DOWNLOAD
Clone the repository:
  git clone https://github.com/yourteam/dmb-agent.git

INSTALL (45 minutes)
Follow the step-by-step guide:
  bash scripts/setup-dmb.sh
  
Or read detailed instructions:
  cat QUICK_START.md

SETUP YOUR ROLE
  Supervisors: Read SUPERVISOR_GUIDE.md
  Operations: Read ADMIN_CHECKLIST.md
  Developers: Read docs/DMB_AGENT_SETUP.md

GET CREDENTIALS
I'm sending credentials separately via secure channel.
Add them to:
  .env
  config/dmb-dispatch.json
  state/holidays/2026.yaml

Questions?
Post in #dmb-support or reply to this email.

Ready? See you on the other side! 🚀

[Your name]
```

---

## ✅ Validation Steps

Once team members install, they should:

```bash
# Verify installation
openclaw skills list | grep dmb-
# Should show 8 dmb-* skills

# Run test
openclaw dmb-orchestrator --test --date 2026-07-20
# Should complete without errors

# Check config
cat .env | head -5
cat config/dmb-dispatch.json | jq '.regions' | head -5
# Should show your values
```

---

## 🎯 Export Timeline

| Step | Time | Owner |
|------|------|-------|
| Prepare export folder | 15 min | You |
| Collect example configs | 10 min | You |
| Extract role guides | 10 min | You |
| Test export | 10 min | You |
| Push to GitHub | 5 min | You |
| Share URL with team | 5 min | You |
| **Total** | **55 min** | |

Then team members:
| Step | Time | Owner |
|------|------|-------|
| Clone repo | 2 min | Team |
| Read QUICK_START | 5 min | Team |
| Run setup-dmb.sh | 45 min | Team |
| Verify installation | 5 min | Team |
| **Total** | **57 min** | |

---

## 📌 Summary

**What to export:**
- skills/ (all 9)
- config/ (templates without credentials)
- scripts/ (setup scripts)
- docs/ (reference)
- README.md, QUICK_START.md, role guides

**What NOT to export:**
- .env (has passwords)
- Real credentials or API keys

**How to share:**
- Git repo (recommended)
- Or zip archive

**Credentials:**
- Share separately via secure channel
- After team clones repo

**Team gets:**
- Complete, ready-to-use system
- Clear installation steps
- Role-specific guides
- Reference documentation

---

## ✨ You're Ready to Export!

Everything your team needs is prepared and organized. 

Next step: Push to GitHub and send the URL! 🚀
