# Docker Skill Updates - Quick Reference

**Fast lookup guide for skill management in Docker containers.**

---

## 🎯 Quick Decision Tree

```
Do you need...?

Latest skills always?
  → YES: Use AUTO_UPDATE_SKILLS=true (development/staging)
  → NO:  Use stable builds (production)

Fast startup?
  → YES: Skills are bundled in image (automatic)
  → NO:  Auto-update takes 5-30 seconds

Predictable versions?
  → YES: Rebuild image quarterly (production)
  → NO:  Auto-update on each restart (development)

Manual control?
  → YES: Use docker-skill-updater.sh (manual commands)
  → NO:  Auto-update does it for you
```

---

## 🚀 Three Strategies at a Glance

| Strategy | When | How | Update |
|----------|------|-----|--------|
| **STABLE** | Production | `docker build` once, deploy for weeks | Rebuild quarterly |
| **ROLLING** | Development | `AUTO_UPDATE_SKILLS=true` | Auto on restart |
| **HYBRID** | Mixed | Stable build + skill checks | Manual when needed |

---

## 💻 Common Commands

### Build Image
```bash
docker build -t dmb-agent:2026-07 .
# Installs all 8 skills at build time
```

### Run (Stable)
```bash
docker run dmb-agent:2026-07 start
# Uses bundled skills, fast startup
```

### Run (Rolling)
```bash
docker run -e AUTO_UPDATE_SKILLS=true dmb-agent:latest start
# Auto-updates skills on startup
```

### Check Skills
```bash
docker exec dmb-agent openclaw skills list | grep dmb-
# Lists installed skills
```

### Update Skills Manually
```bash
docker exec dmb-agent /app/docker-skill-updater.sh update-all
# Update all 8 skills without rebuild/restart
```

### View Skill Logs
```bash
docker exec dmb-agent tail -f /app/logs/skill-updates.log
# Monitor skill operations
```

### Verify All Skills
```bash
docker exec dmb-agent /app/docker-skill-updater.sh check-all
# Shows status of each skill
```

---

## 🔧 Environment Variables

```bash
# Enable/disable skill checking on startup (default: true)
CHECK_SKILLS_ON_START=true|false

# Auto-update missing skills (default: false)
AUTO_UPDATE_SKILLS=true|false

# Path to update logs (default: /app/logs/skill-updates.log)
SKILL_UPDATE_LOG=/app/logs/skill-updates.log
```

---

## 📊 Skill Update Script Commands

```bash
# Update all skills
/app/docker-skill-updater.sh update-all

# Update specific skill
/app/docker-skill-updater.sh update dmb-orchestrator

# Check all skills
/app/docker-skill-updater.sh check-all

# Check specific skill
/app/docker-skill-updater.sh check dmb-draft

# List available skills
/app/docker-skill-updater.sh list

# Show help
/app/docker-skill-updater.sh help
```

---

## 🔄 Update Workflows

### Production (Stable)
```
1. git pull
2. docker build -t dmb-agent:v1.1 .
3. docker push dmb-agent:v1.1
4. Update GitLab variable
5. git push → Pipeline → Deploy
```

### Development (Rolling)
```
1. Run: docker run -e AUTO_UPDATE_SKILLS=true dmb-agent:latest start
2. Skills auto-update on each restart
3. No rebuild needed
```

### Manual (Anytime)
```
1. docker exec dmb-agent /app/docker-skill-updater.sh update-all
2. Done (no restart needed)
```

---

## ✅ Verification Checklist

- [ ] All 8 skills installed: `openclaw skills list | grep -c dmb-`
- [ ] Skills verified: `docker logs dmb-agent | grep "Step 3.5"`
- [ ] No errors: `docker logs dmb-agent | grep ERROR`
- [ ] Startup complete: `docker logs dmb-agent | tail -5`

---

## 🆘 Quick Fixes

**Skills not updating?**
```bash
docker exec dmb-agent /app/docker-skill-updater.sh update-all
```

**Missing skills?**
```bash
docker exec dmb-agent /app/docker-skill-updater.sh check-all
```

**Slow startup?**
```bash
# Disable auto-update if not needed
docker run -e AUTO_UPDATE_SKILLS=false dmb-agent:latest start
```

**Check update logs?**
```bash
docker exec dmb-agent tail -50 /app/logs/skill-updates.log
```

---

## 📚 Full Guides

| Document | Purpose |
|----------|---------|
| `DOCKER_SKILL_UPDATES.md` | Complete strategy guide (this file) |
| `Dockerfile` | Docker image with skill bundling |
| `docker-entrypoint.sh` | Startup script with Step 3.5 |
| `docker-skill-updater.sh` | Skill management utility |
| `DOCKER_DEPLOYMENT.md` | Full deployment guide |
| `DOCKER_GITLAB_SETUP.md` | GitLab CI/CD setup |

---

## 🎯 Recommended Setup

```bash
# Production
docker build -t dmb-agent:2026-07 .
docker run -e CHECK_SKILLS_ON_START=true dmb-agent:2026-07 start

# Development
docker run \
  -e CHECK_SKILLS_ON_START=true \
  -e AUTO_UPDATE_SKILLS=true \
  dmb-agent:latest start

# Update skills quarterly in production
# Update docker build, push to registry, redeploy
```

---

**Version:** 1.0 | **Status:** Production Ready | **Updated:** 2026-07-31
