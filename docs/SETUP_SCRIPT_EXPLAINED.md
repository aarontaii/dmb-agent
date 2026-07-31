# setup-dmb.sh — What It Does & How It Works

**This is the automated setup script that team members run.**

---

## 🎯 What is setup-dmb.sh?

A bash script that:
- ✓ Checks all prerequisites (OpenClaw, Python, Git)
- ✓ Verifies all 8 skills are installed
- ✓ Validates configuration files
- ✓ Creates state directories
- ✓ Tests API connections
- ✓ Runs end-to-end system test
- ✓ Provides completion checklist

**Purpose:** Automate the repetitive setup tasks so team members don't have to manually check everything.

**Time:** Takes about 5 minutes to run (plus ~2 min for the test)

---

## 📋 Step-by-Step Breakdown

### Step 1: Check Prerequisites

```bash
✓ OpenClaw CLI installed
✓ Python 3.8+ installed
✓ Git installed
```

**Why:** Can't run skills without these tools.

**If fails:** Script exits with helpful install links.

---

### Step 2: Verify Skill Installation

```bash
✓ dmb-orchestrator installed
✓ dmb-macro-events installed
✓ dmb-draft installed
✓ dmb-market-data installed
✓ dmb-validate installed
✓ dmb-review-gate installed
✓ dmb-translate installed
✓ dmb-dispatch installed
```

**Why:** All 8 skills must be installed for the system to work.

**If any missing:** Script tells you which ones to install:
```bash
openclaw install skills/dmb-orchestrator
```

---

### Step 3: Validate Configuration Files

**Checks for:**

1. `.env` file exists
   - Contains `TE_API_KEY` (TradingEconomics)
   - Contains `GMAIL_*` (Gmail credentials)
   - Contains `WHATSAPP_*` (WhatsApp credentials)

2. `config/dmb-dispatch.json` exists
   - Contains WhatsApp group IDs (format: `123@g.us`)
   - Contains approver phone numbers (E.164 format)

3. `state/holidays/2026.yaml` exists
   - Market holiday definitions

**If missing:** Script tells you which files to create:
```bash
cp config/te_calendar.env.example .env
cp config/dmb-dispatch.json.example config/dmb-dispatch.json
```

---

### Step 4: Create State Directories

Creates the directory structure for the system to use:

```
state/
├── drafts/           ← Where daily drafts go
├── events/          ← Where macro events are stored
├── marketdata/      ← Where Bloomberg data is stored
└── holidays/        ← Where holiday definitions go
```

**Why:** System needs these to store daily data.

---

### Step 5: Test API Connections

**Checks:**
- TradingEconomics API key is set
- (Actual API test would require making a real API call)

**Output:** Tells you if credentials are detected

---

### Step 6: Run End-to-End System Test

**Most important step!**

```bash
openclaw dmb-orchestrator --test --date 2026-07-20
```

**What it tests:**
1. Can refresh macro events (TradingEconomics)
2. Can draft a brief (write headline, bullets, candidates)
3. Can validate the draft (check all rules)
4. Can process market data (parse figures)
5. Can translate to Chinese
6. Can prepare for dispatch

**If passes:** ✓ System is working correctly

**If fails:** Shows error message so you can fix it

---

### Step 7: Verification Checklist

Script displays a checklist for you to review:

```
SKILLS INSTALLED:
  ☐ dmb-orchestrator
  ☐ dmb-macro-events
  ... (8 total)

CONFIGURATION:
  ☐ .env file configured
  ☐ config/dmb-dispatch.json has group IDs
  ... (4 total)

DIRECTORIES:
  ☐ state/drafts
  ☐ state/events
  ... (4 total)

TESTING:
  ☐ Test run completed successfully
  ☐ Draft JSON created
```

---

## 🚀 How to Run It

### For Team Members

```bash
# After cloning repo and installing skills
bash scripts/setup-dmb.sh

# Output will show progress like:
# ✓ OpenClaw installed: 1.2.3
# ✓ Python 3 installed: 3.9.2
# ✓ Git installed
# ✓ dmb-orchestrator installed
# ✓ dmb-macro-events installed
# ... (more checks)
# ✓ SETUP SUCCESSFUL! 🎉
```

### If Something Fails

```bash
# Script will tell you what's wrong and how to fix it
# For example, if a skill is missing:
# ✗ dmb-orchestrator NOT installed
#   Try: openclaw install skills/dmb-orchestrator

# Fix it, then run again:
bash scripts/setup-dmb.sh
```

---

## 📊 What Happens Behind the Scenes

### 1. Directory Check
```bash
if [ ! -f "QUICK_START.md" ] && [ ! -f "README.md" ]; then
    # Error: Not in dmb-agent directory
fi
```

Makes sure you're running from the correct folder.

---

### 2. Skill Verification Loop

```bash
for skill in dmb-orchestrator dmb-macro-events ... dmb-dispatch; do
    if openclaw skills list | grep "$skill"; then
        # ✓ Skill installed
    else
        # ✗ Skill missing
    fi
done
```

Loops through all 8 skills, checking each one.

---

### 3. Configuration Validation

```bash
if grep -q "TE_API_KEY" .env; then
    # ✓ API key found
else
    # ⚠ API key missing
fi
```

Searches `.env` file for required settings.

---

### 4. Directory Creation

```bash
for dir in state/drafts state/events state/marketdata state/holidays; do
    if [ -d "$dir" ]; then
        # ✓ Directory exists
    else
        mkdir -p "$dir"
        # ✓ Directory created
    fi
done
```

Creates directories if they don't exist.

---

### 5. End-to-End Test

```bash
if openclaw dmb-orchestrator --test --date 2026-07-20 2>/dev/null; then
    # ✓ Test passed
else
    # ⚠ Test failed
fi
```

Runs the actual system on a test date.

---

## 🎨 Output Colors

The script uses colors to make output easy to read:

```
✓  (Green)   — Check passed
✗  (Red)     — Check failed
⚠  (Yellow)  — Warning (not critical)
ℹ  (Blue)    — Information
```

---

## 🔍 What Errors Look Like

If something fails, you'll see:

```bash
✗ dmb-orchestrator NOT installed
  Try: openclaw install skills/dmb-orchestrator

✗ .env file not found
  Create it with: cp config/te_calendar.env.example .env
  Then edit: nano .env

✗ Not all skills are installed!
  Install missing skills with:
    openclaw install skills/dmb-orchestrator
    openclaw install skills/dmb-macro-events
```

Each error tells you **exactly how to fix it**.

---

## ✅ Success Output

When everything passes:

```
========================================
SETUP SUCCESSFUL! 🎉
========================================

Next steps:

1. SUPERVISORS: Read SUPERVISOR_GUIDE.md
   → Learn 5 approval commands

2. ADMINS: Read ADMIN_CHECKLIST.md
   → Schedule daily cron job:
   → openclaw dmb-orchestrator --schedule "0 5 * * 1-5"

3. EVERYONE: Monitor logs
   → openclaw dmb-orchestrator --logs --follow

Ready to go live! 🚀
```

---

## 🆘 If Setup Fails

```bash
# Check prerequisites manually
openclaw --version
python3 --version
git --version

# Check specific skill
openclaw skills list | grep dmb-orchestrator

# Check configuration file
cat .env
cat config/dmb-dispatch.json

# Run test manually
openclaw dmb-orchestrator --test --date 2026-07-20

# View logs
openclaw dmb-orchestrator --logs
```

---

## 📝 Script Features

### Error Handling
- **`set -e`** — Exits on first error (doesn't continue if something fails)
- **Clear messages** — Tells you exactly what's wrong
- **Helpful suggestions** — Includes commands to fix issues

### User-Friendly
- **Color coding** — Easy to spot problems
- **Progress tracking** — Shows what step you're on
- **Counters** — Shows passed/failed checks at end
- **Checklist** — Confirms all items

### Non-Destructive
- **No deletions** — Never deletes anything
- **No overwrites** — Only creates if doesn't exist
- **Reads-only** — Just checks, doesn't modify (except creating dirs)

---

## 🔧 Advanced: Running Individual Checks

If you want to run specific checks manually:

```bash
# Check OpenClaw
openclaw --version

# Check Python
python3 --version

# List installed skills
openclaw skills list

# View configuration
cat .env
cat config/dmb-dispatch.json

# Check directories
ls -la state/

# Run test
openclaw dmb-orchestrator --test --date 2026-07-20

# Check logs
openclaw dmb-orchestrator --logs
```

---

## 📊 Typical Run Output

```
========================================
DMB Agent Setup — Starting Installation
========================================

Running from: /path/to/dmb-agent

========================================
Step 1: Checking Prerequisites
========================================

✓ OpenClaw installed: 1.2.3
✓ Python 3 installed: 3.9.2
✓ Git installed

========================================
Step 2: Verifying Skill Installation
========================================

✓ dmb-orchestrator installed
✓ dmb-macro-events installed
✓ dmb-draft installed
✓ dmb-market-data installed
✓ dmb-validate installed
✓ dmb-review-gate installed
✓ dmb-translate installed
✓ dmb-dispatch installed

ℹ Skills installed: 8 / 8

========================================
Step 3: Validating Configuration
========================================

✓ .env file exists
✓ TradingEconomics API key configured
✓ Gmail credentials configured
✓ WhatsApp credentials configured
✓ config/dmb-dispatch.json exists
✓ Found 3 WhatsApp group IDs

========================================
Step 4: Creating State Directories
========================================

✓ state/drafts exists
✓ state/events exists
✓ state/marketdata exists
✓ state/holidays exists

========================================
Step 5: Testing API Connections
========================================

ℹ Testing TradingEconomics API...
✓ TradingEconomics API key is set

========================================
Step 6: Running System Test
========================================

ℹ Running end-to-end test for 2026-07-20...
(This may take 1-2 minutes)

✓ End-to-end test PASSED
✓ Draft JSON created
✓ Draft contains headline

========================================
Step 7: Verification Checklist
========================================

[Checklist items...]

========================================
Setup Summary
========================================

✓ Checks passed: 32
✗ Checks failed: 0

========================================
SETUP SUCCESSFUL! 🎉
========================================

Ready to go live! 🚀
```

---

## Summary

**setup-dmb.sh is:**
- ✅ **Automated** — Runs 7 steps automatically
- ✅ **Comprehensive** — Checks everything needed
- ✅ **User-friendly** — Clear output, helpful errors
- ✅ **Safe** — Doesn't delete or overwrite anything
- ✅ **Fast** — Takes ~5-7 minutes total

**Team members just run:**
```bash
bash scripts/setup-dmb.sh
```

**And the script guides them through everything!** 🚀
