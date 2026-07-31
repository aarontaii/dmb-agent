# Docker Single Server Deployment Guide

**Simple Docker Compose deployment for single server. Kubernetes comes later.**

---

## 🎯 What This Guide Covers

This guide focuses on deploying DMB Agent on a **single server** using Docker Compose.

- ✅ Simple setup (one config file)
- ✅ Easy scaling (add container replicas)
- ✅ No Kubernetes needed
- ✅ Full skill management included
- ✅ Ready to upgrade to K8s later

**When you're ready for Kubernetes later:** See `DOCKER_DEPLOYMENT.md` for K8s setup.

---

## 📋 Prerequisites

### On Your Single Server

- Docker installed: `docker --version`
- Docker Compose installed: `docker-compose --version`
- 4GB RAM minimum (2GB for container + 2GB buffer)
- 10GB disk minimum (for logs and state)
- Internet connection (for skill updates)

### GitHub/Registry Access

- Docker image built and pushed to registry
- Or: Build locally on server: `docker build -t dmb-agent:latest .`

---

## 🚀 Quick Start (10 minutes)

### Step 1: Copy Files to Server

```bash
# On your local machine
scp Dockerfile user@server:/tmp/dmb-agent/
scp docker-entrypoint.sh user@server:/tmp/dmb-agent/
scp docker-skill-updater.sh user@server:/tmp/dmb-agent/
scp .env.example user@server:/tmp/dmb-agent/

# Or use git
ssh user@server
git clone https://github.com/aarontaii/dmb-agent.git /opt/dmb-agent
cd /opt/dmb-agent
```

### Step 2: Create Docker Compose File

```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  dmb-agent:
    image: docker.io/aarontaii/dmb-agent:latest
    container_name: dmb-agent
    restart: always
    environment:
      TRADING_ECONOMICS_API_KEY: ${TRADING_ECONOMICS_API_KEY}
      GMAIL_USERNAME: ${GMAIL_USERNAME}
      GMAIL_PASSWORD: ${GMAIL_PASSWORD}
      WHATSAPP_API_TOKEN: ${WHATSAPP_API_TOKEN}
      WHATSAPP_PHONE_ID: ${WHATSAPP_PHONE_ID}
      DMB_DISPATCH_GROUPS_JSON: ${DMB_DISPATCH_GROUPS_JSON}
      DMB_HOLIDAYS_YAML: ${DMB_HOLIDAYS_YAML}
      LOG_LEVEL: INFO
      AUTO_UPDATE_SKILLS: "false"
      CHECK_SKILLS_ON_START: "true"
    volumes:
      - dmb-state:/app/state          # Persistent state
      - dmb-logs:/app/logs            # Persistent logs
    ports:
      - "8080:8080"                   # Optional: expose for monitoring
    healthcheck:
      test: ["CMD", "openclaw", "dmb-orchestrator", "--status"]
      interval: 300s
      timeout: 30s
      retries: 3
      start_period: 30s

volumes:
  dmb-state:
  dmb-logs:
EOF
```

### Step 3: Create .env File

```bash
cat > .env << 'EOF'
TRADING_ECONOMICS_API_KEY=your_key_here
GMAIL_USERNAME=your_email@gmail.com
GMAIL_PASSWORD=your_app_password
WHATSAPP_API_TOKEN=your_token_here
WHATSAPP_PHONE_ID=your_phone_id_here
DMB_DISPATCH_GROUPS_JSON='{"regions":{"MY":{"group_id":"xxx@g.us",...}}}'
DMB_HOLIDAYS_YAML='holidays_2026: {...}'
EOF

chmod 600 .env  # Restrict access to .env
```

### Step 4: Build or Pull Image

**Option A: Build on server**
```bash
docker build -t dmb-agent:latest .
```

**Option B: Pull from registry**
```bash
docker login
docker pull docker.io/aarontaii/dmb-agent:latest
```

### Step 5: Start Container

```bash
docker-compose up -d

# Watch startup
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
  ...
✓ Step 4: Running Setup Validation
✓ Step 5: Executing Command

Starting DMB Agent scheduler...
```

Done! Container running on single server. 🎉

---

## 📊 Common Operations

### Check Status

```bash
# List running containers
docker ps | grep dmb-agent

# View logs
docker logs dmb-agent

# Follow logs in real-time
docker logs -f dmb-agent

# Check health
docker exec dmb-agent openclaw dmb-orchestrator --status
```

### Manage Skills

```bash
# Check all skills
docker exec dmb-agent openclaw skills list | grep dmb-

# Verify all skills
docker exec dmb-agent /app/docker-skill-updater.sh check-all

# Update all skills (no rebuild needed)
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# View skill update logs
docker exec dmb-agent tail -f /app/logs/skill-updates.log
```

### Stop/Restart Container

```bash
# Stop
docker-compose down

# Stop and remove volumes (WARNING: loses data!)
docker-compose down -v

# Restart
docker-compose restart

# Restart with new .env values
docker-compose down
# Update .env file
docker-compose up -d
```

### View Logs

```bash
# Last 50 lines
docker logs dmb-agent | tail -50

# Follow logs
docker logs -f dmb-agent

# Search logs
docker logs dmb-agent | grep "ERROR"

# Disk usage
docker exec dmb-agent du -sh /app/logs /app/state
```

---

## 🔄 Update Strategies for Single Server

### Strategy 1: Rebuild Image Quarterly

```bash
# Pull latest code
git pull origin master

# Rebuild image (pulls latest skills)
docker build -t dmb-agent:2026-08 .

# Stop current container
docker-compose down

# Update docker-compose.yml
sed -i 's/dmb-agent:latest/dmb-agent:2026-08/g' docker-compose.yml

# Start new version
docker-compose up -d

# Verify
docker-compose logs | grep "Step 3.5"
```

### Strategy 2: Auto-Update Skills

```bash
# Update docker-compose.yml
# Set: AUTO_UPDATE_SKILLS: "true"

docker-compose down
docker-compose up -d

# Skills auto-update on each restart
```

### Strategy 3: Manual Skill Updates (Anytime)

```bash
# Update skills without rebuild/restart
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# Verify
docker exec dmb-agent /app/docker-skill-updater.sh check-all

# Check logs
docker exec dmb-agent tail -10 /app/logs/skill-updates.log
```

---

## 🔧 Advanced Configuration

### Use Environment File

Instead of hardcoding in docker-compose.yml, reference .env:

```yaml
environment:
  - TRADING_ECONOMICS_API_KEY=${TRADING_ECONOMICS_API_KEY}
  - GMAIL_USERNAME=${GMAIL_USERNAME}
  - GMAIL_PASSWORD=${GMAIL_PASSWORD}
  - WHATSAPP_API_TOKEN=${WHATSAPP_API_TOKEN}
  - WHATSAPP_PHONE_ID=${WHATSAPP_PHONE_ID}
  - DMB_DISPATCH_GROUPS_JSON=${DMB_DISPATCH_GROUPS_JSON}
  - DMB_HOLIDAYS_YAML=${DMB_HOLIDAYS_YAML}
```

### Add Secondary Containers

```yaml
services:
  dmb-agent:
    # ... (above config)

  # Optional: Redis for caching
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  # Optional: PostgreSQL for history
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: dmb_password
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### Enable Monitoring

```yaml
services:
  dmb-agent:
    # ... (config above)

  # Optional: Prometheus scraper
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

---

## 🆘 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs

# Common issues:
# 1. Missing environment variables
docker-compose config  # See what's being used

# 2. Image not found
docker images | grep dmb-agent
docker pull docker.io/aarontaii/dmb-agent:latest

# 3. Port conflict
docker ps | grep 8080
# Change port in docker-compose.yml: "9080:8080"
```

### Skills Not Installed

```bash
# Check if skills installed
docker exec dmb-agent openclaw skills list | grep -c "dmb-"
# Should show: 8

# If less than 8:
docker exec dmb-agent /app/docker-skill-updater.sh update-all

# Check logs
docker exec dmb-agent tail -50 /app/logs/skill-updates.log
```

### Slow Container Startup

```bash
# Check what's slow
docker-compose logs | grep "Step 3"

# If AUTO_UPDATE_SKILLS enabled:
# - Disable it for production: AUTO_UPDATE_SKILLS: "false"

# Check network (if pulling image)
docker pull docker.io/aarontaii/dmb-agent:latest

# Check disk space
df -h
```

### High Memory Usage

```bash
# Check memory
docker stats dmb-agent

# Limits in docker-compose.yml
services:
  dmb-agent:
    deploy:
      resources:
        limits:
          memory: 1G  # Max 1GB
        reservations:
          memory: 512M  # Reserve 512MB
```

### Logs Taking Too Much Space

```bash
# Check log size
du -sh /var/lib/docker/containers/*/

# Rotate logs
docker exec dmb-agent /bin/bash -c 'mv /app/logs/all.log /app/logs/all.log.bak'

# Or configure log rotation in docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

---

## 📈 Scaling Single Server

### Run Multiple Containers

```yaml
version: '3.8'

services:
  # Primary instance
  dmb-agent-1:
    image: dmb-agent:latest
    container_name: dmb-agent-1
    environment:
      # ... (config)
    volumes:
      - dmb-state-1:/app/state
      - dmb-logs-1:/app/logs

  # Secondary instance (for high availability)
  dmb-agent-2:
    image: dmb-agent:latest
    container_name: dmb-agent-2
    environment:
      # ... (config)
    volumes:
      - dmb-state-2:/app/state
      - dmb-logs-2:/app/logs

volumes:
  dmb-state-1:
  dmb-logs-1:
  dmb-state-2:
  dmb-logs-2:
```

### Load Balance Containers

```yaml
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - dmb-agent-1
      - dmb-agent-2
```

---

## 🔐 Security Best Practices

### 1. Use .env File (Not Hardcoded)

```bash
cat > .env << 'EOF'
TRADING_ECONOMICS_API_KEY=secret_key
GMAIL_PASSWORD=secret_password
EOF

chmod 600 .env  # Only owner can read
```

### 2. Use Network Policy

```yaml
networks:
  dmb-internal:
    driver: bridge

services:
  dmb-agent:
    networks:
      - dmb-internal
```

### 3. Run as Non-Root

```bash
# Already done in Dockerfile (user: openclaw)
docker exec dmb-agent whoami  # Should be: openclaw
```

### 4. Limit Container Privileges

```yaml
services:
  dmb-agent:
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    read_only: false  # Needs write for logs/state
```

### 5. Regular Backups

```bash
# Backup state
docker cp dmb-agent:/app/state ./backups/state-$(date +%Y%m%d)

# Backup logs
docker cp dmb-agent:/app/logs ./backups/logs-$(date +%Y%m%d)
```

---

## 📞 When to Move to Kubernetes

You might want Kubernetes when:

- ✅ Running on **multiple servers**
- ✅ Need **automatic scaling**
- ✅ Need **load balancing across servers**
- ✅ Need **auto-restart on node failure**
- ✅ Multiple teams managing infrastructure

For now: **Docker Compose on single server is perfect!**

---

## 🎯 Recommended Setup

### Production (Single Server)

```bash
# File structure
/opt/dmb-agent/
├── docker-compose.yml
├── Dockerfile
├── docker-entrypoint.sh
├── docker-skill-updater.sh
├── .env
└── logs/ (created by container)

# Start
docker-compose up -d

# Monitor
docker-compose logs -f

# Update skills quarterly
docker build -t dmb-agent:2026-08 .
docker-compose down
# Update docker-compose.yml
docker-compose up -d
```

### Development (Single Server)

```bash
# Enable auto-update
AUTO_UPDATE_SKILLS: "true"

docker-compose up -d

# Always latest skills without rebuild
```

### Update Skills Anytime

```bash
# No rebuild, no restart needed
docker exec dmb-agent /app/docker-skill-updater.sh update-all
```

---

## 📚 Full Documentation

- `DOCKER_SKILL_UPDATES.md` — Complete skill strategies
- `DOCKER_SKILL_UPDATES_QUICK_REFERENCE.md` — Quick lookup
- `DOCKER_DEPLOYMENT.md` — When you're ready for K8s
- `DOCKER_GITLAB_SETUP.md` — GitLab CI/CD setup

---

## ✨ Summary

**Simple Single Server Deployment:**

1. Copy files to server
2. Create docker-compose.yml
3. Create .env with secrets
4. `docker-compose up -d`
5. Done!

**Skill updates:**
- Rebuild quarterly for stability
- Or auto-update for development
- Or manual update anytime

**Ready to scale to Kubernetes later?**
See `DOCKER_DEPLOYMENT.md` when needed.

---

**Version:** 1.0 | **Status:** Production Ready | **Updated:** 2026-07-31
