# DMB Agent Docker & GitLab CI/CD Deployment Guide

**Complete automated deployment with zero manual configuration.**

---

## 🎯 Overview

This setup provides:
- **Docker containerization** of the entire DMB Agent system
- **GitLab CI/CD pipeline** for automated building, pushing, and deploying
- **No manual prompts** — all configuration via GitLab CI/CD variables
- **Multiple deployment options**: Docker Compose or Kubernetes
- **Automatic validation** and health checks
- **Production-ready** with restart policies and volume management

---

## 📋 Prerequisites

### Local Requirements
- GitLab account with Docker Registry access
- Docker installed (for local testing)
- kubectl (if deploying to Kubernetes)

### GitLab CI/CD Setup
- GitLab project with CI/CD enabled
- Docker runner or Kubernetes runner configured
- CI/CD variables configured (see below)

---

## 🔐 Required GitLab CI/CD Variables

Configure these in **GitLab** → **Project** → **Settings** → **CI/CD** → **Variables**:

### Docker Registry Credentials
```
DOCKER_REGISTRY          = docker.io  (or registry.gitlab.com)
DOCKER_USERNAME          = your_username
DOCKER_PASSWORD          = your_token_or_password
```

### DMB Agent Configuration
```
TRADING_ECONOMICS_API_KEY = your_te_api_key
GMAIL_USERNAME            = your_gmail@gmail.com
GMAIL_PASSWORD            = your_app_password
WHATSAPP_API_TOKEN        = your_whatsapp_token
WHATSAPP_PHONE_ID         = your_phone_id
```

### Dispatch Configuration (JSON Format)
```
DMB_DISPATCH_GROUPS_JSON = {
  "regions": {
    "MY": {
      "group_id": "123456789-1234567890@g.us",
      "name": "iFAST Malaysia Advisors",
      "approvers": ["+60123456789"]
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

### Market Holidays (YAML Format)
```
DMB_HOLIDAYS_YAML = holidays_2026:
  nyse:
    - date: 2026-01-01
      name: "New Year's Day"
  nasdaq: [same as NYSE]
  hkex:
    - date: 2026-01-29
      name: "Lunar New Year"
  jpx: [...]
  sse: [...]
  sgx: [...]
  bursa:
    - date: 2026-07-07
      name: "Aidilfitri"
  euronext: [...]
```

### Deployment Options

#### For Docker Compose:
```
DOCKER_HOST = tcp://your-docker-host:2375
```

#### For Kubernetes:
```
K8S_CONTEXT   = your-k8s-context
K8S_NAMESPACE = default (or your namespace)
```

---

## 🚀 Deployment Pipelines

### Pipeline Stages

1. **Build** — Docker image creation
2. **Push** — Push to registry
3. **Deploy** — Deploy to Docker Compose or Kubernetes
4. **Validate** — Health checks and verification
5. **Cleanup** — Remove old images (scheduled)

### Trigger Deployment

**Automatic triggers (on push):**
- Push to `main` or `master` branch
- Push tags

**Manual trigger:**
- Kubernetes deployment is `when: manual` (requires click in GitLab UI)

---

## 🏗️ Docker Compose Deployment

### What Gets Deployed

```yaml
services:
  dmb-agent:
    image: ${DOCKER_FULL_IMAGE}
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
    volumes:
      - dmb-state:/app/state          (persistent state)
      - dmb-logs:/app/logs            (persistent logs)
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD", "openclaw", "dmb-orchestrator", "--status"]
      interval: 300s
      timeout: 30s
```

### Local Testing (Before GitLab)

```bash
# 1. Build locally
docker build -t dmb-agent:test .

# 2. Create .env file
cat > .env << EOF
TRADING_ECONOMICS_API_KEY=your_key
GMAIL_USERNAME=your_email
GMAIL_PASSWORD=your_password
WHATSAPP_API_TOKEN=your_token
WHATSAPP_PHONE_ID=your_phone_id
DMB_DISPATCH_GROUPS_JSON=...
DMB_HOLIDAYS_YAML=...
EOF

# 3. Run container
docker run -d \
  --name dmb-test \
  --env-file .env \
  -v dmb-state:/app/state \
  -v dmb-logs:/app/logs \
  dmb-agent:test start

# 4. View logs
docker logs -f dmb-test

# 5. Check status
docker exec dmb-test openclaw dmb-orchestrator --status

# 6. Stop container
docker stop dmb-test
```

---

## ☸️ Kubernetes Deployment

### What Gets Deployed

**Secret** (from environment variables):
```
dmb-agent-secrets
├── TRADING_ECONOMICS_API_KEY
├── GMAIL_USERNAME
├── GMAIL_PASSWORD
├── WHATSAPP_API_TOKEN
├── WHATSAPP_PHONE_ID
├── DMB_DISPATCH_GROUPS_JSON
└── DMB_HOLIDAYS_YAML
```

**ConfigMap** (non-secret config):
```
dmb-agent-config
├── LOG_LEVEL=INFO
└── DEBUG=false
```

**Deployment** (rolling updates):
```
dmb-agent
├── Replicas: 1
├── Image: ${DOCKER_FULL_IMAGE}
├── Env: References to Secret & ConfigMap
├── Volumes: PersistentVolumeClaims
└── Health: Liveness & Readiness probes
```

### Deploy to Kubernetes

```bash
# 1. Create namespace (if needed)
kubectl create namespace dmb-production

# 2. Create secret manually (or via pipeline)
kubectl create secret generic dmb-agent-secrets \
  --from-literal=TRADING_ECONOMICS_API_KEY=your_key \
  --from-literal=GMAIL_USERNAME=your_email \
  --from-literal=GMAIL_PASSWORD=your_password \
  --from-literal=WHATSAPP_API_TOKEN=your_token \
  --from-literal=WHATSAPP_PHONE_ID=your_phone_id \
  --from-literal=DMB_DISPATCH_GROUPS_JSON='...' \
  --from-literal=DMB_HOLIDAYS_YAML='...' \
  -n dmb-production

# 3. Deploy (or trigger via GitLab pipeline)
kubectl apply -f kubernetes-deployment.yaml -n dmb-production

# 4. Check status
kubectl get pods -n dmb-production
kubectl logs deployment/dmb-agent -n dmb-production -f

# 5. Scale if needed
kubectl scale deployment dmb-agent --replicas=3 -n dmb-production
```

---

## 📊 Monitoring & Logs

### Docker Compose

```bash
# Tail logs
docker logs -f dmb-agent

# View status
docker ps | grep dmb-agent

# Exec shell
docker exec -it dmb-agent /bin/bash

# Check health
docker inspect dmb-agent | jq '.State.Health'
```

### Kubernetes

```bash
# View pods
kubectl get pods -n dmb-production

# Tail logs
kubectl logs deployment/dmb-agent -n dmb-production -f

# Get pod logs
kubectl logs dmb-agent-xxxxx -n dmb-production

# Exec shell
kubectl exec -it dmb-agent-xxxxx -n dmb-production -- /bin/bash

# Check events
kubectl describe pod dmb-agent-xxxxx -n dmb-production

# Get metrics
kubectl top pod -n dmb-production
```

---

## 🔧 Entrypoint Commands

The container supports these commands:

```bash
# Start scheduler (default)
docker run dmb-agent:latest start
  └─ Starts DMB scheduler and streams logs

# Run end-to-end test
docker run dmb-agent:latest test [date]
  └─ Tests system on specific date

# Run orchestrator once
docker run dmb-agent:latest run
  └─ Execute pipeline immediately

# Stream logs
docker run dmb-agent:latest logs
  └─ Follow logs

# Check status
docker run dmb-agent:latest status [date]
  └─ Check run status for date

# Validate setup
docker run dmb-agent:latest validate
  └─ Run setup validation

# Interactive shell
docker run -it dmb-agent:latest shell
  └─ Launch bash shell
```

---

## 🏥 Health Checks

### Docker Compose
```
interval: 300s (5 minutes)
timeout: 30s
retries: 3
start_period: 30s
```

### Kubernetes (add to deployment.yaml)
```yaml
livenessProbe:
  exec:
    command:
      - openclaw
      - dmb-orchestrator
      - --status
  initialDelaySeconds: 60
  periodSeconds: 300
  timeoutSeconds: 30
  failureThreshold: 3

readinessProbe:
  exec:
    command:
      - openclaw
      - dmb-orchestrator
      - --status
  initialDelaySeconds: 30
  periodSeconds: 60
  timeoutSeconds: 10
  failureThreshold: 3
```

---

## 📈 CI/CD Pipeline Flow

```
┌─ Commit to main/master
│
├─ Build Stage
│  └─ docker build → DOCKER_FULL_IMAGE
│
├─ Push Stage
│  └─ docker push → Registry
│
├─ Deploy Stage (Choose One)
│  ├─ Docker Compose: docker-compose up -d
│  └─ Kubernetes: kubectl set image + rollout
│
├─ Validate Stage
│  ├─ Check container running
│  └─ Verify logs/status
│
└─ Cleanup Stage (Nightly)
   └─ Remove old images
```

---

## 🔑 Security Best Practices

1. **Use GitLab Secret Variables:**
   - Mark as **Protected** (only on main branch)
   - Mark as **Masked** (won't show in logs)

2. **Use Access Tokens, Not Passwords:**
   - Gmail: Use App Passwords
   - Docker: Use Personal Access Tokens
   - WhatsApp: Use official API tokens

3. **Rotate Credentials Regularly:**
   - Update GitLab variables every 3 months
   - Monitor access logs

4. **Limit Container Privileges:**
   - Run as non-root user (1000)
   - No `--privileged` flag
   - Read-only root filesystem where possible

5. **Network Security:**
   - Use private Docker registries
   - VPN for external connections
   - Network policies in Kubernetes

---

## 🆘 Troubleshooting

### Build Fails

```bash
# Check build logs in GitLab CI/CD
# Common issues:
# - Missing DOCKER_REGISTRY variable
# - Invalid Docker credentials
# - Insufficient disk space in runner

# Solution:
# 1. Verify credentials
# 2. Check runner disk space
# 3. Check OpenClaw installation in Dockerfile
```

### Deployment Fails

```bash
# For Docker Compose:
docker logs dmb-agent
# Check: DOCKER_HOST, credentials, volumes

# For Kubernetes:
kubectl describe deployment dmb-agent
kubectl logs deployment/dmb-agent
# Check: Secret created, resources available, image pull
```

### Container Won't Start

```bash
# Check entrypoint script
docker run -it dmb-agent:latest /bin/bash
bash /app/docker-entrypoint.sh validate

# Check environment variables
docker run -it dmb-agent:latest env | grep -i dmb

# Verify OpenClaw CLI
docker run -it dmb-agent:latest openclaw --version
```

### Health Check Failing

```bash
# Manually test health check
docker exec dmb-agent openclaw dmb-orchestrator --status

# Check for errors
docker logs dmb-agent | tail -50

# Verify skills installed
docker exec dmb-agent openclaw skills list | grep dmb-
```

---

## 📚 Files Included

```
├── Dockerfile                  (Container image definition)
├── docker-entrypoint.sh       (Startup script, environment setup)
├── .gitlab-ci.yml             (CI/CD pipeline definition)
├── docker-compose.prod.yml    (Generated during deploy)
├── kubernetes-deployment.yaml (Kubernetes manifests)
└── DOCKER_DEPLOYMENT.md       (This file)
```

---

## 🚀 Quick Start

### 1. Add GitLab Variables
Go to GitLab → Project Settings → CI/CD → Variables

Add all variables from "Required GitLab CI/CD Variables" section above.

### 2. Commit & Push
```bash
git add Dockerfile docker-entrypoint.sh .gitlab-ci.yml
git commit -m "Add Docker & GitLab CI/CD deployment"
git push origin main
```

### 3. Monitor Pipeline
GitLab → CI/CD → Pipelines → Watch build, push, deploy

### 4. Verify Deployment
```bash
# Docker Compose
docker ps | grep dmb-agent
docker logs dmb-agent

# Kubernetes
kubectl get pods -n dmb-production
kubectl logs deployment/dmb-agent -n dmb-production
```

---

## 📞 Support

- **Build issues?** Check GitLab CI/CD logs
- **Runtime issues?** Check container/pod logs
- **Configuration issues?** Verify all CI/CD variables are set
- **Health checks failing?** Run `validate` command in container

---

**Version:** 1.0  
**Status:** Production Ready  
**Updated:** 2026-07-31
