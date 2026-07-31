# DMB Agent System — Distribution Package Index

**Version:** 1.0  
**System:** iFAST Daily Market Brew (9 coordinated OpenClaw skills)  
**Status:** Production-ready, ready to distribute

---

## 📦 What's Included

Two comprehensive guides covering the entire DMB Agent system:

### 1. **DMB_AGENT_SETUP.md** (Technical Reference)
   - Complete system architecture
   - Daily workflow pipeline with diagram
   - All 9 skills explained in detail
   - State structure and data flow
   - Configuration guide
   - Manual operations (monitor, troubleshoot)
   - Development & extension guide
   - Deployment checklist

### 2. **DMB_DISTRIBUTION_GUIDE.md** (Distribution & Rollout)
   - Distribution methods (Git, Archive, Registry)
   - 3 role-specific guides (templates inside):
     - **DMB_SUPERVISOR_GUIDE.md** — For research team
     - **DMB_ADMIN_GUIDE.md** — For operations/DevOps
     - **DMB_DEV_GUIDE.md** — For developers
   - Communication templates (email, Slack)
   - Rollout timeline (3-week plan)
   - Support structure & escalation
   - Complete deployment checklist

---

## 🎯 Quick Links

| Need | Document | Time |
|------|----------|------|
| **Understand the system** | DMB_AGENT_SETUP.md | 30 min |
| **Deploy to your team** | DMB_DISTRIBUTION_GUIDE.md | 20 min |
| **As a supervisor** | DMB_SUPERVISOR_GUIDE.md (in guide) | 5 min |
| **As ops/admin** | DMB_ADMIN_GUIDE.md (in guide) | 30 min |
| **As a developer** | DMB_DEV_GUIDE.md (in guide) | 1 hour |
| **Set up system** | DMB_AGENT_SETUP.md → "Installation" | 45 min |
| **Deploy production** | DMB_DISTRIBUTION_GUIDE.md → checklist | 1.5 hours |

---

## 📊 The 9 Skills

**Core Pipeline (8 required):**
- 📣 **dmb-orchestrator** — Conductor, sequences pipeline
- 🗓️ **dmb-macro-events** — TradingEconomics calendar
- ✍️ **dmb-draft** — Writes daily brief
- 📊 **dmb-market-data** — Bloomberg email parsing
- 🧪 **dmb-validate** — Deterministic rule checking
- ✅ **dmb-review-gate** — Supervisor approval commands
- 🀄 **dmb-translate** — English → Chinese translation
- 📤 **dmb-dispatch** — WhatsApp to 3 advisor regions

**Optional Extension:**
- ☕ **dmb-market-brew** — WhatsApp group monitoring + web scraping (separate setup)

---

## 🚀 Get Started

### For Team Leaders / Admins

1. **Read:** `DMB_AGENT_SETUP.md` (30 min)
   - Understand system architecture
   - See daily workflow

2. **Read:** `DMB_DISTRIBUTION_GUIDE.md` (20 min)
   - Choose distribution method
   - Plan rollout timeline

3. **Follow:** Deployment Checklist
   - Install system
   - Configure credentials
   - Test end-to-end
   - Deploy and monitor

### For Supervisors (Research Team)

1. **Read:** `DMB_SUPERVISOR_GUIDE.md` (5 min)
2. **Learn** 5 approval commands:
   - `APPROVE`
   - `APPROVE PICK n,m,o,p,q`
   - `EDIT n <text>`
   - `REJECT <reason>`
   - `STATUS`

### For Developers

1. **Read:** `DMB_AGENT_SETUP.md` (system architecture)
2. **Read:** `DMB_DEV_GUIDE.md` (extension guide)
3. **Review:** All SKILL.md files in `skills/dmb-*/`
4. **Study:** References (`editorial-rules.md`, `format-spec.md`)

---

## 📈 Daily Operation

```
08:05 MYT    Orchestrator starts
   ↓
             Refresh macro calendar
             Verify market closures
             Draft brief
             Validate
             Post review pack to working group
   ↓
~07:55 MYT   Bloomberg email arrives (during above)
   ↓
~10:00 MYT   Supervisor reviews in WhatsApp
   ↓
~12:00 MYT   Supervisor approves/edits
   ↓
             Translate to Chinese
             Validate Chinese
   ↓
~12:15 MYT   Dispatch to 3 advisor regions
   ↓
~12:20 MYT   Done! Write receipts
```

**Total automation:** 95%  
**Manual component:** 5-minute supervisor approval in WhatsApp

---

## ✅ Key Features

✓ **Complete setup guide** — Everything from Git clone to first production run  
✓ **Role-specific documentation** — Supervisors, admins, and developers get what they need  
✓ **Pre-written templates** — Email, Slack, communication, deployment checklist  
✓ **Troubleshooting guide** — Common issues with fixes and escalation paths  
✓ **Support structure** — Defined Slack channels, on-call rotation, escalation procedures  
✓ **3-week rollout plan** — Week 1: setup, Week 2: soft launch, Week 3: full automation  
✓ **Development guide** — How to extend, modify, and improve the system  

---

## 📋 Deployment Checklist (Summary)

**Pre-distribution:**
- [ ] Review editorial rules (`editorial-rules.md`)
- [ ] Verify output format (`format-spec.md`)
- [ ] Test on past date
- [ ] Confirm all credentials work
- [ ] Collect supervisor phone numbers

**Distribution:**
- [ ] Choose method (Git recommended)
- [ ] Prepare role-specific guides
- [ ] Draft communication
- [ ] Schedule team walkthrough

**Installation & Setup:**
- [ ] Install all 9 skills
- [ ] Configure (TE API, holidays, WhatsApp groups)
- [ ] Add supervisor E.164s to allowlist
- [ ] Test end-to-end
- [ ] Schedule cron (05:00 UTC, weekdays)

**Go-Live:**
- [ ] Monitor first 3 runs closely
- [ ] Troubleshoot issues
- [ ] Get feedback
- [ ] Adjust as needed

---

## 📚 Document Locations

All files in: `/home/openclaw/.openclaw/workspace-dmb/`

```
workspace-dmb/
├── README_DISTRIBUTION.md           ← You are here
├── DMB_AGENT_SETUP.md              ← Technical reference (50 KB)
├── DMB_DISTRIBUTION_GUIDE.md       ← Distribution guide (40 KB)
│
└── skills/
    ├── dmb-orchestrator/SKILL.md
    ├── dmb-macro-events/SKILL.md
    ├── dmb-draft/
    │   ├── SKILL.md
    │   └── references/
    │       ├── format-spec.md       ← Canonical output templates
    │       └── editorial-rules.md   ← Writing guidelines
    ├── dmb-market-data/SKILL.md
    ├── dmb-validate/SKILL.md
    ├── dmb-review-gate/SKILL.md
    ├── dmb-translate/SKILL.md
    └── dmb-dispatch/SKILL.md
```

---

## 🎓 Next Steps

### Today: Understand the System
- [ ] Read `DMB_AGENT_SETUP.md` overview
- [ ] Understand 9-skill pipeline
- [ ] Review daily workflow

### This Week: Plan Distribution
- [ ] Read `DMB_DISTRIBUTION_GUIDE.md`
- [ ] Choose distribution method (Git recommended)
- [ ] Prepare role-specific guides
- [ ] Draft team communication

### Next Week: Install & Test
- [ ] Gather credentials (TE API, Bloomberg, WhatsApp)
- [ ] Follow installation guide
- [ ] Test on past date
- [ ] Verify all validation rules pass

### Week 3: Soft Launch
- [ ] Deploy to team
- [ ] Run first briefings with manual dispatch
- [ ] Gather feedback
- [ ] Train supervisors on approval commands

### Week 4: Full Automation
- [ ] Enable automatic dispatch
- [ ] Monitor closely
- [ ] Document any issues
- [ ] Publish runbooks

---

## ❓ FAQs

**Q: How long does setup take?**  
A: 45 min to 1.5 hours depending on credential availability and testing thoroughness.

**Q: Do supervisors need technical training?**  
A: No. They learn 5 simple WhatsApp commands (APPROVE, EDIT, REJECT, STATUS, HOLD).

**Q: What if something breaks?**  
A: The system fails loudly and alerts the working group. Never sends partial/corrupted content.

**Q: Can we customize the briefs?**  
A: Yes. Supervisors can edit headline, bullets, and individual items before approval.

**Q: Is there a fallback if automation fails?**  
A: Yes. The system includes a REJECT command so supervisors can stop the day and do manual process.

**Q: What if the Bloomberg email doesn't arrive?**  
A: System holds at "awaiting_figures" and alerts the group by 07:55 MYT.

**Q: Can we add more advisor groups?**  
A: Yes. Update `config/dmb-dispatch.json` and redeploy. No code changes needed.

**Q: What about holidays when markets are closed?**  
A: The system checks `state/holidays/2026.yaml` and skips closed markets automatically.

---

## 📞 Support

For questions about:
- **System architecture** → See `DMB_AGENT_SETUP.md`
- **Distribution** → See `DMB_DISTRIBUTION_GUIDE.md`
- **Supervisor commands** → See `DMB_SUPERVISOR_GUIDE.md` (in guide)
- **Deployment/ops** → See `DMB_ADMIN_GUIDE.md` (in guide)
- **Extensions/fixes** → See `DMB_DEV_GUIDE.md` (in guide)

---

## ✨ You're Ready!

This complete package includes everything needed to share the iFAST Daily Market Brew system with your team.

- ✅ **Technical documentation** covering all 9 skills
- ✅ **Distribution methods** for easy setup
- ✅ **Role-specific guides** for supervisors, admins, developers
- ✅ **Communication templates** for team announcements
- ✅ **Deployment checklist** so nothing gets forgotten
- ✅ **Troubleshooting guide** for common issues
- ✅ **Support structure** with escalation paths

**Next step:** Open `DMB_AGENT_SETUP.md` or `DMB_DISTRIBUTION_GUIDE.md` and begin.

---

**Package Version:** 1.0  
**Created:** 2026-07-31  
**System:** iFAST Daily Market Brew Agent (8 skills + 1 optional)  
**Status:** Production Ready ✨
