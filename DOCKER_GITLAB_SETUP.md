# Docker + GitLab CI/CD Automated Deployment Setup

**Complete step-by-step guide to deploy DMB Agent without manual prompts.**

---

## 🎯 What You'll Have

✅ Fully automated Docker-based deployment  
✅ Zero manual configuration (all via GitLab variables)  
✅ Two deployment options: Docker Compose or Kubernetes  
✅ Automatic scaling and health checks  
✅ CI/CD pipeline from git push to production  

---

## 📋 Step 1: Prepare Your GitLab Repository

### 1.1 Copy Docker Files to Repository

After you've already pushed to GitHub, add these files to your repo:

```bash
cd ~/dmb-export

# Copy Docker files from workspace
cp /home/openclaw/.openclaw/workspace-dmb/Dockerfile .
cp /home/openclaw/.openclaw/workspace-dmb/docker-entrypoint.sh .
cp /home/openclaw/.openclaw/workspace-dmb/.gitlab-ci.yml .
cp /home/openclaw/.openclaw/workspace-dmb/kubernetes-deployment.yaml .
cp /home/openclaw/.openclaw/workspace-dmb/DOCKER_DEPLOYMENT.md .

# Make entrypoint executable
chmod +x docker-entrypoint.sh

# Commit and push
git add Dockerfile docker-entrypoint.sh .gitlab-ci.yml kubernetes-deployment.yaml DOCKER_DEPLOYMENT.md
git commit -m "Add Docker & GitLab CI/CD automated deployment"
git push origin master
```

### 1.2 Create .dockerignore

```bash
cat > .dockerignore << 'EOF'
.git
.gitignore
.gitlab-ci.yml
.env
.env.*
*.log
state/drafts/*
state/events/*
state/marketdata/*
docs/
README.md
DOCKER_DEPLOYMENT.md
node_modules/
__pycache__/
*.pyc
.DS_Store
EOF

git add .dockerignore
git commit -m "Add .dockerignore for smaller Docker image"
git push origin master
```

---

## 🔐 Step 2: Set Up GitLab CI/CD Variables

### 2.1 Access GitLab CI/CD Variables

1. Go to your GitLab project: **https://gitlab.com/aarontaii/dmb-agent**
2. Click: **Settings** → **CI/CD** → **Variables**
3. Click: **Add variable**

### 2.2 Add All Required Variables

**Type: Variable (not file)**
**Masked: ✓ (enable to hide in logs)**
**Protected: ✓ (only on protected branches)**

Add these variables:

```
Variable Name                   | Value
------------------------------- | -----------
DOCKER_REGISTRY                 | docker.io
DOCKER_USERNAME                 | aarontaii
DOCKER_PASSWORD                 | your_docker_token_here
TRADING_ECONOMICS_API_KEY       | your_te_api_key
GMAIL_USERNAME                  | your_gmail@gmail.com
GMAIL_PASSWORD                  | your_app_password
WHATSAPP_API_TOKEN              | your_whatsapp_token
WHATSAPP_PHONE_ID               | your_phone_id
```

### 2.3 Add Dispatch Configuration (JSON)

**Type: Variable**
**Masked: ✓**
**Protected: ✓**

```
Variable: DMB_DISPATCH_GROUPS_JSON
Value: (paste this JSON, replace with your actual values)

{
  "regions": {
    "MY": {
      "group_id": "123456789-1234567890@g.us",
      "name": "iFAST Malaysia Advisors",
      "approvers": ["+60123456789", "+60187654321"]
    },
    "SG": {
      "group_id": "987654321-9876543210@g.us",
      "name": "iFAST Singapore Advisors",
      "approvers": ["+6581234567"]
    },
    "HK": {
      "group_id": "555666777-5555666777@g.us",
      "name": "iFAST Hong Kong Advisors",
      "approvers": ["+85298765432"]
    }
  },
  "working_group_id": "111222333-111222333@g.us",
  "working_group_name": "DMB Research Team"
}
```

### 2.4 Add Holidays Configuration (YAML)

**Type: Variable**
**Masked: ✓**
**Protected: ✓**

```
Variable: DMB_HOLIDAYS_YAML
Value: (paste your holidays YAML)

holidays_2026:
  nyse:
    - date: 2026-01-01
      name: "New Year's Day"
  nasdaq:
    - date: 2026-01-01
      name: "New Year's Day"
  hkex:
    - date: 2026-01-29
      name: "Lunar New Year"
  jpx:
    - date: 2026-01-11
      name: "Coming of Age Day"
  sse:
    - date: 2026-02-10
      name: "Lunar New Year Holiday"
  sgx:
    - date: 2026-02-10
      name: "Chinese New Year"
  bursa:
    - date: 2026-07-07
      name: "Aidilfitri"
  euronext:
    - date: 2026-01-01
      name: "New Year's Day"
```

### 2.5 Optional: Deployment Variables

If deploying to Docker Compose:
```
DOCKER_HOST = tcp://your-docker-host:2375
```

If deploying to Kubernetes:
```
K8S_CONTEXT = your-cluster-context
K8S_NAMESPACE = dmb-production
```

---

## ✅ Step 3: Verify Setup

### 3.1 Check Variables Are Set

1. Go to: **Settings** → **CI/CD** → **Variables**
2. Verify all 8 required variables are listed
3. Verify **Masked** ✓ and **Protected** ✓ are enabled

### 3.2 Trigger First Pipeline

1. Go to: **CI/CD** → **Pipelines**
2. Click: **Run Pipeline**
3. Select branch: `master`
4. Click: **Create pipeline**

---

## 🚀 Step 4: Deploy to Production

### Option A: Docker Compose Deployment

#### Prerequisites
- Docker Host accessible via DOCKER_HOST variable
- Docker daemon running and exposed

#### Deploy

1. Pipeline will automatically:
   - Build Docker image
   - Push to registry
   - Create docker-compose.prod.yml
   - Deploy via `docker-compose up -d`

2. Monitor:
   ```bash
   # From your Docker host
   docker ps | grep dmb-agent
   docker logs -f dmb-agent
   ```

### Option B: Kubernetes Deployment

#### Prerequisites
- Kubernetes cluster
- kubectl configured
- K8S_CONTEXT and K8S_NAMESPACE set in GitLab

#### Deploy Manually (First Time)

```bash
# 1. Create secret
kubectl create secret generic dmb-agent-secrets \
  --from-literal=TRADING_ECONOMICS_API_KEY=your_key \
  --from-literal=GMAIL_USERNAME=your_email \
  --from-literal=GMAIL_PASSWORD=your_password \
  --from-literal=WHATSAPP_API_TOKEN=your_token \
  --from-literal=WHATSAPP_PHONE_ID=your_phone_id \
  --from-literal=DMB_DISPATCH_GROUPS_JSON='{"regions":{...}}' \
  --from-literal=DMB_HOLIDAYS_YAML='holidays_2026:...' \
  -n dmb-production

# 2. Create ConfigMap
kubectl create configmap dmb-agent-config \
  --from-literal=LOG_LEVEL=INFO \
  --from-literal=DEBUG=false \
  -n dmb-production

# 3. Create PersistentVolumes (if not using dynamic provisioning)
kubectl apply -f kubernetes-deployment.yaml -n dmb-production

# 4. Verify
kubectl get pods -n dmb-production
kubectl logs deployment/dmb-agent -n dmb-production -f
```

#### Deploy via GitLab Pipeline

1. Go to: **CI/CD** → **Pipelines** → Latest
2. Click: **deploy:kubernetes** job
3. Click: **Play** (manual trigger button)

---

## 📊 Step 5: Monitor Deployment

### Docker Compose

```bash
# View container status
docker ps | grep dmb-agent

# View logs
docker logs dmb-agent
docker logs -f dmb-agent  # Follow logs

# Check health
docker inspect dmb-agent | jq '.State.Health'

# Execute commands
docker exec dmb-agent openclaw dmb-orchestrator --status

# Stop/restart
docker stop dmb-agent
docker restart dmb-agent
```

### Kubernetes

```bash
# View pods
kubectl get pods -n dmb-production
kubectl get pods -n dmb-production -o wide

# View logs
kubectl logs deployment/dmb-agent -n dmb-production
kubectl logs -f deployment/dmb-agent -n dmb-production

# View events
kubectl describe pod dmb-agent-xxxxx -n dmb-production

# Execute commands
kubectl exec -it dmb-agent-xxxxx -n dmb-production -- /bin/bash
kubectl exec dmb-agent-xxxxx -n dmb-production -- openclaw dmb-orchestrator --status

# Check resource usage
kubectl top pod -n dmb-production
kubectl top nodes
```

---

## 🔄 Step 6: Continuous Updates

### Automatic Redeployment

After initial setup, updates are automatic:

1. Make code changes
2. `git push` to master
3. GitLab pipeline triggers automatically:
   - Build new image
   - Push to registry
   - Deploy (rolling update)

### Manual Redeployment

```bash
# Kubernetes - Force image pull
kubectl set image deployment/dmb-agent \
  dmb-agent=docker.io/aarontaii/dmb-agent:latest \
  -n dmb-production --record

kubectl rollout status deployment/dmb-agent -n dmb-production

# Docker Compose
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml restart
```

---

## 🧪 Step 7: Test Before Full Deployment

### Local Docker Test

```bash
# 1. Build image locally
docker build -t dmb-agent:test .

# 2. Create .env file
cat > .env.test << EOF
TRADING_ECONOMICS_API_KEY=your_key
GMAIL_USERNAME=your_email
GMAIL_PASSWORD=your_password
WHATSAPP_API_TOKEN=your_token
WHATSAPP_PHONE_ID=your_phone_id
DMB_DISPATCH_GROUPS_JSON='{"regions":{...}}'
DMB_HOLIDAYS_YAML='holidays_2026:...'
EOF

# 3. Run test
docker run --env-file .env.test dmb-agent:test test 2026-07-20

# 4. Check logs
docker logs $(docker ps -q -f status=exited) | tail -50

# 5. Cleanup
docker rm $(docker ps -q -f status=exited)
```

### Staging Kubernetes Test

Deploy to separate namespace before production:

```bash
# Deploy to staging namespace
kubectl create namespace dmb-staging
kubectl apply -f kubernetes-deployment.yaml -n dmb-staging

# Run test
kubectl exec deployment/dmb-agent -n dmb-staging -- \
  /app/docker-entrypoint.sh test 2026-07-20

# Check results
kubectl logs deployment/dmb-agent -n dmb-staging

# Cleanup if satisfied
kubectl delete namespace dmb-staging
```

---

## ⚙️ Configuration Management

### Updating Variables

Need to change a configuration?

1. Go to: **Settings** → **CI/CD** → **Variables**
2. Edit the variable
3. Next push (or manual pipeline run) uses new value

### Secrets Rotation

Every 3 months:
1. Generate new API keys from respective services
2. Update GitLab variables
3. Trigger pipeline (automatic redeployment)

### Environment Variable Hierarchy

Variables are applied in order (first wins):
1. Docker/K8s secret (from GitLab variable)
2. .env file (if exists)
3. Default (built-in)

---

## 🆘 Troubleshooting

### Build Fails

**"Docker login failed"**
```
✓ Check DOCKER_USERNAME and DOCKER_PASSWORD
✓ Verify Docker token (not password)
✓ Confirm registry URL (docker.io or registry.gitlab.com)
```

**"OpenClaw installation failed"**
```
✓ Check internet connectivity in runner
✓ Verify curl can reach openclaw.dev
✓ Check Docker runner has sufficient disk space
```

### Deployment Fails

**"Container won't start"**
```bash
# Check logs
docker logs dmb-agent

# Run entrypoint manually
docker run -it dmb-agent:latest validate

# Common issues:
# - Missing environment variables
# - Invalid API keys
# - Skills installation failed
```

**"Health check failing"**
```bash
# Test health check manually
docker exec dmb-agent openclaw dmb-orchestrator --status

# If fails:
# - Wait 60s for startup (initialDelaySeconds: 60)
# - Check logs for errors
# - Verify skills installed
```

### Pipeline Stuck

1. Go to: **CI/CD** → **Pipelines**
2. Click stuck job
3. Click **Cancel** if needed
4. Check job logs for error
5. Fix and push again

---

## 📚 File Reference

| File | Purpose |
|------|---------|
| `Dockerfile` | Container image definition |
| `docker-entrypoint.sh` | Startup script, env setup, command execution |
| `.gitlab-ci.yml` | CI/CD pipeline definition |
| `kubernetes-deployment.yaml` | K8s manifests (Secret, ConfigMap, Deployment) |
| `DOCKER_DEPLOYMENT.md` | Complete Docker deployment guide |
| `DOCKER_GITLAB_SETUP.md` | This file - step-by-step setup |

---

## ✨ Summary

**You now have:**

✅ Docker image that runs without manual prompts  
✅ GitLab CI/CD pipeline that automates build → push → deploy  
✅ All configuration via GitLab variables (no .env files!)  
✅ Two deployment options (Docker Compose or Kubernetes)  
✅ Automatic rolling updates on git push  
✅ Health checks and monitoring  

**To deploy:**

1. Set GitLab variables (Step 2)
2. Push code (Step 3)
3. Pipeline runs automatically
4. Done!

**To update:**

Just push changes → pipeline auto-redeploys!

---

**Version:** 1.0  
**Status:** Production Ready  
**Updated:** 2026-07-31
