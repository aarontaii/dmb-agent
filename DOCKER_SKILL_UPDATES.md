# Docker Image Skill Updates Strategy

**How to keep your DMB Agent Docker image up-to-date with latest OpenClaw skills.**

---

## 🎯 Overview

Your Docker image has three layers of skill management:

1. **Build-Time Bundling** — Skills installed during Docker build (fast startup)
2. **Runtime Verification** — Skills verified when container starts (ensures compatibility)
3. **Auto-Update Option** — Optionally update skills on container startup (always latest)

This provides flexibility: choose between **stability** (bundled skills) or **freshness** (auto-update).

---

## 📦 How It Works

### Layer 1: Build-Time Bundling

When you run `docker build`:

```dockerfile
RUN openclaw install /app/skills/dmb-orchestrator && \
    openclaw install /app/skills/dmb-macro-events && \
    openclaw install /app/skills/dmb-draft && \
    ... (all 8 skills)
```

All 8 skills are pre-installed in the image.

**Benefits:**
- Fast container startup (no installation delay)
- Reproducible builds (specific versions)
- Works offline (no network calls at runtime)

**Trade-off:**
- Need to rebuild image for skill updates

### Layer 2: Runtime Verification

When container starts:

```bash
CHECK_SKILLS_ON_START=true (default)
```

Entrypoint verifies all skills are still installed.

**Benefits:**
- Detects missing/corrupted skills
- Validates compatibility
- Logs any issues

**Trade-off:**
- Adds 10-20 seconds to startup

### Layer 3: Auto-Update (Optional)

If you enable auto-update:

```bash
docker run -e AUTO_UPDATE_SKILLS=true dmb-agent:latest start
```

Container automatically updates any missing/outdated skills.

**Benefits:**
- Always runs latest skill versions
- No manual rebuild needed
- Automatic skill fixes

**Trade-off:**
- Requires internet connection
- Slower startup (5-30 seconds extra)
- Different versions across container restarts

---

## 🚀 Three Update Strategies

Choose the one that fits your needs:

### Strategy 1: Stable (Recommended for Production)

Build image once, use for weeks/months.

```bash
# Build image (installs specific skill versions)
docker build -t dmb-agent:v1.0 .

# Push to registry
docker push aarontaii/dmb-agent:v1.0

# Deploy with bundled skills
docker run dmb-agent:v1.0 start
```

**When to update:**
- Quarterly (update all dependencies together)
- When new features needed
- When bugs fixed

**Update Process:**
1. `git pull` latest skill code
2. `docker build -t dmb-agent:v1.1 .` (rebuilds with new skills)
3. `docker push aarontaii/dmb-agent:v1.1`
4. Update GitLab variable: `DOCKER_FULL_IMAGE=...v1.1`
5. Push code → pipeline redeploys

### Strategy 2: Rolling (Development/Staging)

Always use latest skills, rebuild frequently.

```bash
# Enable auto-update in .gitlab-ci.yml
deploy:docker-compose:
  variables:
    AUTO_UPDATE_SKILLS: "true"
```

**When to use:**
- Development environment
- Staging before production release
- Testing new skill features

**Update Process:**
1. Skills auto-update on every container restart
2. No rebuild needed
3. No git push needed
4. Container always has latest skills

### Strategy 3: Hybrid (Best of Both)

Production uses stable builds, but checks for updates.

```bash
# Build image once (stable)
docker build -t dmb-agent:latest .

# Deploy with skill checking enabled
docker run \
  -e CHECK_SKILLS_ON_START=true \
  -e AUTO_UPDATE_SKILLS=false \
  dmb-agent:latest start
```

**Features:**
- Fast startup (uses bundled skills)
- Detects missing skills
- Manual update when needed

---

## 🔧 Configuration Options

### Environment Variables

Control skill behavior with environment variables:

```bash
# Enable skill verification on startup (default: true)
CHECK_SKILLS_ON_START=true

# Auto-update missing/outdated skills (default: false)
AUTO_UPDATE_SKILLS=false

# Path to skill update log
SKILL_UPDATE_LOG=/app/logs/skill-updates.log
```

### Docker Compose Example

```yaml
services:
  dmb-agent:
    image: dmb-agent:latest
    environment:
      # Enable both checking and auto-update
      CHECK_SKILLS_ON_START: "true"
      AUTO_UPDATE_SKILLS: "true"
      LOG_LEVEL: INFO
    volumes:
      - dmb-logs:/app/logs
```

### Kubernetes Example

```yaml
env:
- name: AUTO_UPDATE_SKILLS
  value: "true"
- name: CHECK_SKILLS_ON_START
  value: "true"
```

---

## 📊 Skill Update Script

The container includes `docker-skill-updater.sh` for manual skill management.

### Usage

```bash
# Update all skills
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# Update specific skill
docker exec dmb-agent /app/docker-skill-updater.sh update dmb-orchestrator

# Check skill status
docker exec dmb-agent /app/docker-skill-updater.sh check-all

# List available skills
docker exec dmb-agent /app/docker-skill-updater.sh list
```

### Manual Update Example

```bash
# Connect to running container
docker exec -it dmb-agent /bin/bash

# Inside container
/app/docker-skill-updater.sh update-all

# Check logs
tail -f /app/logs/skill-updates.log
```

---

## 🔄 GitLab CI/CD Skill Updates

### Option A: Rebuild on Each Push (Stable)

```bash
# .gitlab-ci.yml
build:docker:
  script:
    - docker build -t $DOCKER_FULL_IMAGE .
    # Skills installed at build time ↑
```

**Update triggers:**
- `git push` → pipeline → rebuild → new image → redeploy

### Option B: Auto-Update on Startup (Rolling)

```bash
# .gitlab-ci.yml
deploy:docker-compose:
  variables:
    AUTO_UPDATE_SKILLS: "true"
  script:
    - docker-compose up -d
```

**Update triggers:**
- Any container restart → auto-update skills

### Option C: Manual Update Command

```bash
# From GitLab pipeline job
deploy:update-skills:
  stage: deploy
  script:
    - docker exec dmb-agent /app/docker-skill-updater.sh update-all
  when: manual
```

**Update triggers:**
- Manual click in GitLab UI

---

## 📈 Update Timeline

### Daily Workflow

```
Morning (automatic on container startup)
    ↓
Check skills installed (CHECK_SKILLS_ON_START=true)
    ↓
If missing & AUTO_UPDATE_SKILLS=true
    → Update skills (1-5 minutes)
    ↓
Start scheduler
    ↓
Daily briefings running
```

### Weekly Update (Stable)

```
Monday
    ↓
Developer: git pull latest skills
    ↓
Developer: docker build -t dmb-agent:v1.1 .
    ↓
Developer: docker push aarontaii/dmb-agent:v1.1
    ↓
Developer: Update GitLab variable
    ↓
Developer: git push code
    ↓
Pipeline: Build → Push → Deploy
    ↓
Container: Starts with v1.1 skills
    ↓
Fresh skills, known stable version
```

### On-Demand Update

```
Developer needs skill fix NOW
    ↓
1. Get latest skill from source
    ↓
2. Option A: docker exec -it dmb-agent bash
   /app/docker-skill-updater.sh update dmb-orchestrator
    ↓
3. Option B: Trigger manual pipeline job
    ↓
4. Skill updated immediately
    ↓
5. Test thoroughly before production
    ↓
6. Schedule official rebuild for consistency
```

---

## ✅ Monitoring Skill Updates

### Check Skill Status

```bash
# List installed skills
docker exec dmb-agent openclaw skills list | grep dmb-

# Expected output:
# dmb-orchestrator
# dmb-macro-events
# dmb-draft
# dmb-market-data
# dmb-validate
# dmb-review-gate
# dmb-translate
# dmb-dispatch
```

### View Update Logs

```bash
# Stream update logs
docker exec dmb-agent tail -f /app/logs/skill-updates.log

# View specific skill update
docker exec dmb-agent grep "dmb-orchestrator" /app/logs/skill-updates.log
```

### Kubernetes Monitoring

```bash
# Check pod startup logs
kubectl logs pod/dmb-agent-xxxxx -n dmb-production

# Grep for skill checks
kubectl logs pod/dmb-agent-xxxxx -n dmb-production | grep -i "skill"

# Stream logs during startup
kubectl logs pod/dmb-agent-xxxxx -n dmb-production -f
```

---

## 🚨 Troubleshooting

### Skills Not Updating

**Problem:** Skills aren't updating even with `AUTO_UPDATE_SKILLS=true`

**Solution:**
```bash
# 1. Check current setting
docker exec dmb-agent echo $AUTO_UPDATE_SKILLS

# 2. Manually update
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# 3. Check logs
docker exec dmb-agent tail -50 /app/logs/skill-updates.log

# 4. Verify network connectivity
docker exec dmb-agent curl https://openclaw.dev

# 5. Check disk space
docker exec dmb-agent df -h /app
```

### Missing Skills on Startup

**Problem:** Container starts but some skills are missing

**Solution:**
```bash
# 1. Enable skill checking
docker exec dmb-agent \
  /app/docker-entrypoint.sh validate

# 2. Manually install missing skill
docker exec dmb-agent \
  /app/docker-skill-updater.sh update dmb-orchestrator

# 3. Or restart container with AUTO_UPDATE_SKILLS
docker restart dmb-agent \
  -e AUTO_UPDATE_SKILLS=true
```

### Slow Container Startup

**Problem:** Container takes too long to start

**Solution:**
```bash
# Disable skill checking on startup
docker run \
  -e CHECK_SKILLS_ON_START=false \
  dmb-agent:latest start

# Or disable auto-update
docker run \
  -e AUTO_UPDATE_SKILLS=false \
  dmb-agent:latest start

# Monitor startup
docker run --rm dmb-agent:latest validate
```

---

## 📋 Best Practices

### ✅ DO

- ✅ Use **stable builds** for production (rebuild quarterly)
- ✅ Use **auto-update** for development (always latest)
- ✅ Monitor `skill-updates.log` for issues
- ✅ Test skill updates in staging first
- ✅ Tag images with versions (v1.0, v1.1, etc.)
- ✅ Use `CHECK_SKILLS_ON_START=true` in all deployments

### ❌ DON'T

- ❌ Use `AUTO_UPDATE_SKILLS=true` in production (unpredictable)
- ❌ Manually edit skill files in running container
- ❌ Push to production without testing updates
- ❌ Ignore skill update errors in logs
- ❌ Use `latest` tag for production (use versioned tags)

---

## 🎯 Recommended Setup

### For Production

```bash
# Build image (installs specific skill versions)
docker build -t dmb-agent:2026-07 .

# Deploy with skill checking (detects issues)
docker run \
  -e CHECK_SKILLS_ON_START=true \
  -e AUTO_UPDATE_SKILLS=false \
  dmb-agent:2026-07 start

# Update process:
# 1. Update skills in git (monthly/quarterly)
# 2. docker build -t dmb-agent:2026-08 .
# 3. docker push dmb-agent:2026-08
# 4. Update GitLab variable
# 5. Push code → automatic redeploy
```

### For Development/Staging

```bash
# Build image once
docker build -t dmb-agent:dev .

# Deploy with auto-update (always latest)
docker run \
  -e CHECK_SKILLS_ON_START=true \
  -e AUTO_UPDATE_SKILLS=true \
  dmb-agent:dev start

# Skills auto-update on each container restart
```

---

## 🔗 Related Files

- `Dockerfile` — Docker image definition with skill installation
- `docker-entrypoint.sh` — Startup script with skill checking
- `docker-skill-updater.sh` — Manual skill update script
- `.gitlab-ci.yml` — CI/CD pipeline with build options

---

## 📞 Support

- **Skills missing?** Run: `docker exec dmb-agent /app/docker-skill-updater.sh check-all`
- **Update failed?** Check: `/app/logs/skill-updates.log`
- **Need manual update?** Use: `/app/docker-skill-updater.sh update-all`
- **Questions?** Check `DOCKER_DEPLOYMENT.md` for complete deployment guide

---

**Version:** 1.0  
**Status:** Production Ready  
**Updated:** 2026-07-31
