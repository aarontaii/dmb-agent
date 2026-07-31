# DMB Agent — Quick Reference Card

**Print this or share with your team!**

---

## 📦 BEFORE EXPORTING TO TEAM

**You (Admin) do ONCE:**

```bash
# 1. Prepare export folder
mkdir dmb-agent && cd dmb-agent/
git init

# 2. Copy skills folder
cp -r /path/to/skills ./

# 3. Copy config templates (WITHOUT credentials!)
mkdir config/
cp [your examples] config/*.example

# 4. Create setup script
mkdir scripts/
# (See TEAM_EXPORT_CONTENTS.md for template)

# 5. Create state directories
mkdir -p state/{drafts,events,marketdata,holidays}

# 6. Extract role guides and README
# (See TEAM_EXPORT_CONTENTS.md for details)

# 7. Commit and push
git add .
git commit -m "Initial: DMB Agent v1.0"
git remote add origin [your-repo-url]
git push -u origin main
```

**Share with team:**
```
GitHub URL: https://github.com/yourteam/dmb-agent.git
(Team clones and follows QUICK_START.md)
```

---

## 🚀 TEAM INSTALLATION (45 MIN)

**Team member does THIS (follows QUICK_START.md):**

```bash
# 1. Clone (5 min)
git clone https://github.com/yourteam/dmb-agent.git
cd dmb-agent/

# 2. Install skills (10 min)
openclaw install skills/dmb-orchestrator
openclaw install skills/dmb-macro-events
openclaw install skills/dmb-draft
openclaw install skills/dmb-market-data
openclaw install skills/dmb-validate
openclaw install skills/dmb-review-gate
openclaw install skills/dmb-translate
openclaw install skills/dmb-dispatch

# 3. Configure credentials (10 min)
cp config/te_calendar.env.example .env
nano .env
# Add: TE_API_KEY, GMAIL_USERNAME, GMAIL_PASSWORD, WHATSAPP_API_TOKEN, WHATSAPP_PHONE_ID

# 4. Configure dispatch & holidays (5 min)
cp config/dmb-dispatch.json.example config/dmb-dispatch.json
nano config/dmb-dispatch.json
# Add: group IDs, approver phone numbers

cp config/holidays.example.yaml state/holidays/2026.yaml
nano state/holidays/2026.yaml
# Verify holidays

# 5. Automated setup (5 min)
bash scripts/setup-dmb.sh
# Validates everything

# 6. Test (10 min)
openclaw dmb-orchestrator --test --date 2026-07-20
# Should succeed without errors

# 7. Verify (5 min)
openclaw skills list | grep dmb-
# Should show 8 dmb-* skills
```

✓ **DONE!** System is ready.

---

## ✅ VERIFICATION CHECKLIST

**Team member verifies:**

```
SKILLS:
☐ dmb-orchestrator
☐ dmb-macro-events
☐ dmb-draft
☐ dmb-market-data
☐ dmb-validate
☐ dmb-review-gate
☐ dmb-translate
☐ dmb-dispatch

CONFIG:
☐ .env has TradingEconomics API key
☐ .env has Gmail credentials
☐ .env has WhatsApp credentials
☐ config/dmb-dispatch.json has 3 group IDs (MY, SG, HK)
☐ config/dmb-dispatch.json has approver E.164s (+601234567890)
☐ state/holidays/2026.yaml loaded

TESTS:
☐ Test run completed successfully
☐ Draft JSON created
☐ No "FAILED" messages

READY FOR PRODUCTION:
☐ All above ✓
☐ Can schedule daily cron job
```

---

## 🎯 DAILY OPERATION

**Supervisors (Research Team):**

```
1. Read: SUPERVISOR_GUIDE.md
2. Wait for brief in WhatsApp working group (~08:15 MYT)
3. Review proposed 5 items
4. Give approval command:
   
   APPROVE                          ← Accept as-is
   APPROVE PICK 2,5,7,9,13         ← Override with your 5
   EDIT HEADLINE New headline text  ← Change headline
   EDIT 3 New item text            ← Change item #3
   REJECT Reason for rejection     ← Stop the day
   STATUS                          ← Show progress
```

**Admins (Operations/DevOps):**

```
1. Read: ADMIN_CHECKLIST.md
2. Schedule: openclaw dmb-orchestrator --schedule "0 5 * * 1-5"
3. Daily (takes 5 min):
   openclaw dmb-orchestrator --status --date $(date +%Y-%m-%d)
   openclaw dmb-orchestrator --logs --since 1h
4. Monitor for errors
5. Support team as needed
```

**Developers:**

```
1. Read: docs/DMB_AGENT_SETUP.md
2. Can extend:
   - Add validation rules (validate.py)
   - Add editorial rules (editorial-rules.md)
   - Add new data sources (new skill)
   - Fix bugs (any SKILL.md)
```

---

## 🔐 CREDENTIALS (Send Separately!)

**DO NOT include in export:**
- ❌ .env file
- ❌ API keys or tokens
- ❌ Gmail passwords
- ❌ Real group IDs

**DO include in export:**
- ✅ .env.example (template)
- ✅ config examples (templates)
- ✅ .gitignore (prevents accidents)

**Share credentials separately (secure channel):**
```
TradingEconomics API Key: [key]
Gmail Account: [email]
Gmail App Password: [password]
WhatsApp API Token: [token]
WhatsApp Phone ID: [id]
```

"Copy these into your local .env file. Don't commit to git."

---

## 📞 TROUBLESHOOTING

**"Skill not found"**
```bash
openclaw install skills/dmb-orchestrator
openclaw skills list | grep dmb-
```

**"API key invalid"**
```bash
# Check .env
cat .env | grep API_KEY
# Regenerate at https://tradingeconomics.com/api/keys
# Update .env
```

**"Group not found"**
```bash
# Get from WhatsApp Group Info → JID
# Update config/dmb-dispatch.json
# Format: 123456789-1234567890@g.us
```

**"Gmail auth failed"**
```bash
# Enable 2FA on Gmail
# Create app password: https://myaccount.google.com/apppasswords
# Use app password (not regular password) in .env
```

**"Test failed"**
```bash
openclaw dmb-orchestrator --logs --date 2026-07-20
# Check error message
# Fix issue
# Rerun test
```

---

## 📊 FILE STRUCTURE

```
dmb-agent/
├── README.md                    ← START HERE
├── QUICK_START.md              ← Installation steps
├── SUPERVISOR_GUIDE.md         ← Approval commands
├── ADMIN_CHECKLIST.md          ← Setup/monitoring
├── skills/                     ← 8 skills
├── config/                     ← Templates (no credentials!)
├── scripts/                    ← setup-dmb.sh, test-dmb.sh
├── state/                      ← Empty directories
├── docs/                       ← Full documentation
└── .gitignore                  ← Blocks .env from git
```

---

## ⏱️ TIMELINE

```
YOU (Preparation):     55 minutes
├─ Prepare export:     15 min
├─ Collect configs:    10 min
├─ Extract guides:     10 min
├─ Test export:        10 min
└─ Push to GitHub:     10 min

TEAM (Per Person):     57 minutes
├─ Clone repo:          2 min
├─ Read guide:          5 min
├─ Run setup:          45 min
└─ Verify:             5 min

YOU (Handoff):         7 minutes
├─ Share credentials:   5 min
└─ Announce:           2 min
```

---

## 🎯 SUCCESS INDICATORS

Team knows it's working when:

```
✓ All 8 skills installed (openclaw skills list)
✓ setup-dmb.sh completes without errors
✓ Test run succeeds
✓ All verification items checked
✓ Brief appears in working group daily (starting ~08:15 MYT)
✓ Supervisors can approve/edit via WhatsApp
✓ System translates to Chinese automatically
✓ Briefs dispatch to MY, SG, HK advisor groups
✓ Receipts logged successfully
```

---

## 📚 DOCUMENT MAP

| Need | Document |
|------|----------|
| **How to export** | TEAM_EXPORT_CONTENTS.md |
| **Installation steps** | EXPORT_AND_INSTALL.md |
| **System architecture** | DMB_AGENT_SETUP.md |
| **Supervisor commands** | SUPERVISOR_GUIDE.md |
| **Admin/ops guide** | ADMIN_CHECKLIST.md |
| **Developer guide** | DMB_DEV_GUIDE.md |
| **Full distribution guide** | DMB_DISTRIBUTION_GUIDE.md |

---

## 💡 KEY POINTS

- **Installation is automated** — `bash setup-dmb.sh` does most work
- **Supervisors need 5 minutes** — Just approval commands
- **Admins need 45 minutes** — Setup once, then 5 min daily
- **Credentials are separate** — Never in the export
- **Everything is tested** — Validation before sending
- **System fails loudly** — Alerts you if something's wrong
- **No partial sends** — All-or-nothing delivery

---

## 🚀 NEXT STEPS

1. **Read** TEAM_EXPORT_CONTENTS.md (how to prepare export)
2. **Prepare** export folder with files
3. **Test** export on clean machine
4. **Push** to GitHub
5. **Share** URL with team
6. **Send** credentials separately (secure channel)
7. **Support** team during installation
8. **Celebrate** 🎉

---

**Version:** 1.0  
**Last Updated:** 2026-07-31  
**Questions?** See full docs or contact your admin
