# iFAST Daily Market Brew Agent

Automated daily market intelligence system with supervisor approval, Chinese translation, and dispatch to advisor groups across Malaysia, Singapore, and Hong Kong.

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

## 8 Coordinated Skills

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

## Installation

See [QUICK_START.md](QUICK_START.md) for detailed installation steps.

Quick version:
```bash
git clone https://github.com/yourname/dmb-agent.git
cd dmb-agent/
bash scripts/setup-dmb.sh
```

## Roles

**Supervisors:** Read [SUPERVISOR_GUIDE.md](SUPERVISOR_GUIDE.md)  
**Admins:** Read [ADMIN_CHECKLIST.md](ADMIN_CHECKLIST.md)

## Support

Post questions in #dmb-support Slack channel or contact your admin.

---

Version: 1.0  
Status: Production Ready
