# DMB Agent - Daily Market Brew for OpenClaw

**Automated daily market briefings across multiple regions using OpenClaw skills and WhatsApp distribution.**

---

## 🎯 What is DMB Agent?

The Daily Market Brew (DMB) Agent is a coordinated system of **8 OpenClaw skills** that:

1. **Collect** macro events and market data from multiple sources
2. **Analyze** trading economics data, market sentiment, and technical signals
3. **Draft** comprehensive market briefings for each region
4. **Validate** data accuracy and completeness
5. **Review** for trading recommendations and gate-keeping
6. **Translate** briefings to local languages
7. **Dispatch** via WhatsApp to regional teams
8. **Orchestrate** all steps on a daily schedule

**All this runs automatically** on a single Docker container!

---

## 📦 The 8 Skills

| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `dmb-orchestrator` | Coordinates entire pipeline | Schedule | Orchestration |
| `dmb-macro-events` | Collects macro events | APIs | Market events JSON |
| `dmb-draft` | Drafts briefing document | Events + Data | Markdown briefing |
| `dmb-market-data` | Fetches market data | APIs | Price/volume data |
| `dmb-validate` | Validates data quality | Data | Quality report |
| `dmb-review-gate` | Reviews for recommendations | Briefing | Trading signals |
| `dmb-translate` | Translates to local languages | Briefing | Translated text |
| `dmb-dispatch` | Sends via WhatsApp | Briefing | Delivery status |

---

## 🚀 Quick Start

### Prerequisites

- Docker installed: `docker --version`
- Docker Compose installed: `docker-compose --version`
- 4GB RAM, 10GB disk minimum

### Setup (5 minutes)

```bash
# 1. Clone or copy this repo
git clone https://github.com/aarontaii/dmb-agent.git
cd dmb-agent

# 2. Create .env with your credentials
cp .env.example .env
# Edit .env with your API keys, Gmail, WhatsApp credentials

# 3. Start the agent
docker-compose up -d

# 4. Watch logs
docker-compose logs -f
```

**Expected output:**
```
✓ Step 1: Validating Environment Variables
✓ Step 2: Creating Configuration Files
✓ Step 3: Installing OpenClaw Skills
✓ Step 3.5: Checking Installed Skills
  ✓ Verified: dmb-orchestrator
  ✓ Verified: dmb-macro-events
  ... (all 8 skills)
✓ Step 4: Running Setup Validation
Starting DMB Agent scheduler...
```

Done! Running daily briefings. ✨

---

## 📁 Project Structure

```
dmb-agent/
├── Dockerfile                                    # Docker image definition
├── docker-compose.yml                           # Docker Compose setup
├── docker-entrypoint.sh                         # Container startup script
├── docker-skill-updater.sh                      # Skill management utility
├── .gitlab-ci.yml                               # GitLab CI/CD pipeline
├── kubernetes-deployment.yaml                   # Kubernetes manifests
├── .gitignore                                   # Git ignore rules
│
├── skills/
│   ├── dmb-orchestrator/                        # Skill 1: Orchestration
│   ├── dmb-macro-events/                        # Skill 2: Event collection
│   ├── dmb-draft/                               # Skill 3: Draft briefing
│   ├── dmb-market-data/                         # Skill 4: Market data
│   ├── dmb-validate/                            # Skill 5: Validation
│   ├── dmb-review-gate/                         # Skill 6: Review/gate
│   ├── dmb-translate/                           # Skill 7: Translation
│   └── dmb-dispatch/                            # Skill 8: WhatsApp dispatch
│
├── config/
│   └── dmb-dispatch.json                        # WhatsApp group config
│
├── state/
│   ├── drafts/                                  # Generated briefings
│   ├── events/                                  # Market events cache
│   ├── marketdata/                              # Market data cache
│   └── holidays/                                # Market holidays by year
│
├── scripts/
│   └── setup-dmb.sh                             # Setup validation script
│
├── docs/
│   ├── QUICK_REFERENCE.md                       # Quick start card
│   ├── DMB_AGENT_SETUP.md                       # Technical setup guide
│   ├── DMB_DISTRIBUTION_GUIDE.md                # Team distribution guide
│   ├── EXPORT_AND_INSTALL.md                    # Installation for team
│   ├── TEAM_EXPORT_CONTENTS.md                  # What to export
│   ├── SETUP_SCRIPT_EXPLAINED.md                # Setup script breakdown
│   └── README_DISTRIBUTION.md                   # Distribution overview
│
├── DEPLOYMENT.md (Folder)
│   ├── DOCKER_SINGLE_SERVER_DEPLOYMENT.md       # Single server setup
│   ├── DOCKER_DEPLOYMENT.md                     # Full Docker guide
│   ├── DOCKER_GITLAB_SETUP.md                   # GitLab CI/CD setup
│   ├── DOCKER_SKILL_UPDATES.md                  # Skill update strategies
│   └── DOCKER_SKILL_UPDATES_QUICK_REFERENCE.md  # Skill management quick ref
│
└── README.md (this file)
```

---

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Required: Trading Economics API
TRADING_ECONOMICS_API_KEY=your_key_here

# Required: Gmail for market data
GMAIL_USERNAME=your_email@gmail.com
GMAIL_PASSWORD=your_app_password

# Required: WhatsApp Business API
WHATSAPP_API_TOKEN=your_token_here
WHATSAPP_PHONE_ID=your_phone_id

# Required: WhatsApp group configuration (JSON)
DMB_DISPATCH_GROUPS_JSON='{"regions":{"MY":{"group_id":"..."}}}'

# Required: Market holidays (YAML)
DMB_HOLIDAYS_YAML='holidays_2026: {...}'

# Optional: Logging
LOG_LEVEL=INFO
DEBUG=false
```

### WhatsApp Groups Configuration

Edit `config/dmb-dispatch.json`:

```json
{
  "regions": {
    "MY": {
      "group_id": "120363xxx@g.us",
      "name": "iFAST Malaysia Advisors",
      "approvers": ["+60123456789"]
    },
    "SG": {
      "group_id": "120363yyy@g.us",
      "name": "iFAST Singapore Advisors",
      "approvers": ["+6581234567"]
    },
    "HK": {
      "group_id": "120363zzz@g.us",
      "name": "iFAST Hong Kong Advisors",
      "approvers": ["+85298765432"]
    }
  },
  "working_group_id": "120363www@g.us",
  "working_group_name": "DMB Research Team"
}
```

---

## 📊 Daily Workflow

### What Happens Every Weekday at 5:00 AM

```
5:00 AM → dmb-orchestrator triggers
  │
  ├─→ dmb-macro-events: Collect macroeconomic events
  │
  ├─→ dmb-market-data: Fetch market prices, volumes
  │
  ├─→ dmb-draft: Generate briefing document
  │
  ├─→ dmb-validate: Verify data quality
  │
  ├─→ dmb-review-gate: Add trading recommendations
  │
  ├─→ dmb-translate: Translate to local languages (EN, ZH, BM)
  │
  └─→ dmb-dispatch: Send to WhatsApp groups
        │
        ├─ @Malaysia
        ├─ @Singapore
        └─ @Hong Kong

8:00 AM → Team reviews briefings on WhatsApp
9:00 AM → Trading decisions made with fresh insights
```

---

## 🎯 Common Commands

### Docker Compose

```bash
# Start container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Restart container
docker-compose restart

# Check status
docker-compose ps
```

### Check Skills

```bash
# List installed skills
docker exec dmb-agent openclaw skills list | grep dmb-

# Verify all skills
docker exec dmb-agent /app/docker-skill-updater.sh check-all

# Update all skills
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# View skill logs
docker exec dmb-agent tail -f /app/logs/skill-updates.log
```

### Manual Operations

```bash
# Run test
docker exec dmb-agent /app/docker-entrypoint.sh test 2026-07-20

# Check status
docker exec dmb-agent /app/docker-entrypoint.sh status

# View briefing state
docker exec dmb-agent ls -la /app/state/drafts/

# Interactive shell
docker exec -it dmb-agent /bin/bash
```

---

## 📈 Skill Update Strategies

### Strategy 1: Stable (Production)

Build image once, deploy for weeks/months:

```bash
docker build -t dmb-agent:2026-07 .
docker-compose down
# Update docker-compose.yml
docker-compose up -d
```

**Update:** Rebuild quarterly

### Strategy 2: Rolling (Development)

Always use latest skills:

```bash
# Set in docker-compose.yml
AUTO_UPDATE_SKILLS: "true"
docker-compose restart
```

**Update:** Automatic on restart

### Strategy 3: Manual (Anytime)

Update without rebuild/restart:

```bash
docker exec dmb-agent /app/docker-skill-updater.sh update-all
```

**Update:** Instant (10 seconds)

---

## 🚀 Deployment Options

### Single Server (Recommended for Now)

Docker Compose on one server. See: `DOCKER_SINGLE_SERVER_DEPLOYMENT.md`

```bash
docker-compose up -d
```

### Kubernetes (Later)

When you need multiple servers, load balancing, auto-scaling. See: `DOCKER_DEPLOYMENT.md`

```bash
kubectl apply -f kubernetes-deployment.yaml
```

### GitLab CI/CD (Automated)

Automatic build, push, deploy on git push. See: `DOCKER_GITLAB_SETUP.md`

```bash
git push → Pipeline → Deployed
```

---

## 🔐 Security

### Sensitive Data

- API keys and passwords in `.env` file (never in git)
- `.env` ignored in `.gitignore`
- Use app passwords, not real passwords
- Rotate credentials every 3 months

### Container Security

- Runs as non-root user (`openclaw`)
- No privilege escalation
- Minimal required permissions
- Network isolation by default

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `QUICK_REFERENCE.md` | One-page quick start |
| `DMB_AGENT_SETUP.md` | Complete technical setup |
| `DMB_DISTRIBUTION_GUIDE.md` | How to distribute to team |
| `DOCKER_SINGLE_SERVER_DEPLOYMENT.md` | Single server Docker setup |
| `DOCKER_SKILL_UPDATES.md` | Skill update strategies |
| `DOCKER_DEPLOYMENT.md` | Full deployment guide (K8s) |
| `DOCKER_GITLAB_SETUP.md` | GitLab CI/CD automation |

---

## 🆘 Troubleshooting

### Container won't start

```bash
docker-compose logs
# Check for missing environment variables
```

### Skills not installed

```bash
docker exec dmb-agent /app/docker-skill-updater.sh check-all
docker exec dmb-agent /app/docker-skill-updater.sh update-all
```

### Slow startup

```bash
# Disable auto-update if enabled
docker-compose down
# Edit docker-compose.yml: AUTO_UPDATE_SKILLS=false
docker-compose up -d
```

### WhatsApp delivery failing

```bash
# Check dispatch logs
docker exec dmb-agent grep -i "whatsapp" /app/logs/*.log
# Verify WHATSAPP_API_TOKEN and WHATSAPP_PHONE_ID in .env
```

See full troubleshooting in `DOCKER_SINGLE_SERVER_DEPLOYMENT.md`

---

## 🤝 Contributing

1. Clone this repo
2. Create feature branch: `git checkout -b feature/improve-drafts`
3. Make changes
4. Test: `docker build -t dmb-agent:test . && docker run dmb-agent:test validate`
5. Commit: `git commit -m "improve: better draft formatting"`
6. Push: `git push origin feature/improve-drafts`
7. Open pull request

---

## 📅 Roadmap

- ✅ Core 8 skills coordinated
- ✅ Docker containerization
- ✅ Single server deployment
- ✅ Skill update strategies
- 📋 Kubernetes deployment (in progress)
- 📋 GitLab CI/CD automation (in progress)
- 🔮 Multi-language support (planned)
- 🔮 Web UI for monitoring (planned)
- 🔮 Advanced trading signals (planned)

---

## 📞 Support

- **Setup issues?** See `DOCKER_SINGLE_SERVER_DEPLOYMENT.md`
- **Skill problems?** See `DOCKER_SKILL_UPDATES.md`
- **Want to distribute?** See `DMB_DISTRIBUTION_GUIDE.md`
- **Technical details?** See `DMB_AGENT_SETUP.md`

---

## 📄 License

[Your License Here]

---

## 👥 Team

- **Project Owner:** Aaron Tai (@aarontaii)
- **Contributors:** [Add your name here]

---

**Version:** 1.0  
**Status:** Production Ready  
**Last Updated:** 2026-07-31

---

## Quick Links

- 🎯 [Quick Reference](QUICK_REFERENCE.md)
- 🚀 [Single Server Deployment](DOCKER_SINGLE_SERVER_DEPLOYMENT.md)
- 📚 [Full Documentation](DMB_AGENT_SETUP.md)
- 🔧 [Skill Updates](DOCKER_SKILL_UPDATES.md)
- 🌍 [Team Distribution](DMB_DISTRIBUTION_GUIDE.md)
