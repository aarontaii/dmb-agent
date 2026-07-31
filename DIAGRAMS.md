# DMB Agent - Deployment Architecture Diagrams

**Visual diagrams showing how the DMB Agent deployment works end-to-end.**

---

## 📊 Complete Deployment Flow

Shows the entire system from GitHub repository to regional teams receiving daily briefings.

```mermaid
graph TD
    A["📦 GitHub Repository<br/>aarontaii/dmb-agent"] -->|git clone| B["💻 Team Member Server"]
    
    B -->|"1. Create .env<br/>2. docker-compose up"| C["🐳 Docker Compose<br/>Single Server Deployment"]
    
    C -->|"Build & Start"| D["🚀 Docker Container<br/>DMB Agent"]
    
    D -->|"Step 1-2: Setup"| E["⚙️ Initialization<br/>- Validate env vars<br/>- Create config files"]
    
    E -->|"Step 3-3.5: Skills"| F["🎯 8 OpenClaw Skills"]
    
    F --> F1["dmb-orchestrator<br/>Coordination"]
    F --> F2["dmb-macro-events<br/>Event Collection"]
    F --> F3["dmb-draft<br/>Briefing Generation"]
    F --> F4["dmb-market-data<br/>Market Data"]
    F --> F5["dmb-validate<br/>Data Quality"]
    F --> F6["dmb-review-gate<br/>Trading Signals"]
    F --> F7["dmb-translate<br/>Translation"]
    F --> F8["dmb-dispatch<br/>WhatsApp Delivery"]
    
    F1 -->|Coordinates| F2
    F2 -->|Feeds| F3
    F4 -->|Feeds| F3
    F3 -->|Feeds| F5
    F5 -->|Feeds| F6
    F6 -->|Feeds| F7
    F7 -->|Feeds| F8
    
    D -->|"Step 4-5: Execution"| G["📊 Persistent Data"]
    G --> G1["state/drafts<br/>Generated Briefings"]
    G --> G2["state/events<br/>Market Events"]
    G --> G3["state/marketdata<br/>Market Data Cache"]
    G --> G4["logs/<br/>Operation Logs"]
    
    F8 -->|WhatsApp APIs| H["📱 WhatsApp Groups<br/>MY | SG | HK"]
    
    F2 -->|APIs| I["📈 External Data Sources<br/>Trading Economics"]
    F4 -->|APIs| I
    F4 -->|Email| J["📧 Gmail<br/>Bloomberg Emails"]
    
    H -->|Delivers| K["👥 Regional Teams<br/>Malaysia<br/>Singapore<br/>Hong Kong"]
    
    K -->|Daily Briefings| L["✅ Trading Decisions<br/>Market Analysis<br/>Regional Insights"]
```

---

## 🖥️ Single Server Architecture (Docker Compose)

Shows what runs on a single server using Docker Compose.

```mermaid
graph LR
    subgraph Server["🖥️ Single Server (Linux/Ubuntu)"]
        subgraph Docker["🐳 Docker Engine"]
            subgraph Container["📦 DMB Agent Container<br/>(Non-root user: openclaw)"]
                EntryPoint["docker-entrypoint.sh<br/>Smart Startup Script"]
                Skills["8 OpenClaw Skills<br/>Pre-installed"]
                Scheduler["Scheduler<br/>Runs 5am Weekdays"]
            end
            
            Volumes["📁 Docker Volumes<br/>Persistent Storage"]
        end
    end
    
    EntryPoint -->|Verifies| Skills
    Skills -->|Logs to| Volumes
    Scheduler -->|Orchestrates| Skills
    
    Env["🔐 .env File<br/>Secrets & Config"]
    Env -->|Environment Variables| Container
    
    Volumes -->|state/| State["Drafts<br/>Events<br/>Market Data"]
    Volumes -->|logs/| Logs["skill-updates.log<br/>dmb-*.log"]
    
    External["🌐 External APIs"]
    External -->|Trading Econ| Skills
    External -->|Gmail| Skills
    External -->|WhatsApp| Skills
    
    Skills -->|Sends| WhatsApp["📱 WhatsApp<br/>Regional Groups"]
    
    style Container fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Volumes fill:#2196F3,stroke:#1565C0,color:#fff
    style Server fill:#FFC107,stroke:#FFA000,color:#000
    style Docker fill:#2496ED,stroke:#0066CC,color:#fff
```

---

## ⏰ Daily Skill Pipeline Execution

Shows what happens each day at 5:00 AM when the orchestrator triggers all skills.

```mermaid
graph TD
    subgraph Daily["⏰ Daily Execution<br/>5:00 AM Weekdays"]
        Orch["dmb-orchestrator<br/>Main Coordinator"]
    end
    
    Orch -->|"Trigger 1"| Event["dmb-macro-events<br/>Collect economic events<br/>from Trading Econ API"]
    Orch -->|"Trigger 2"| Market["dmb-market-data<br/>Fetch market data<br/>from Bloomberg email"]
    
    Event -->|"Market Events"| Draft["dmb-draft<br/>Generate briefing<br/>document"]
    Market -->|"Price/Volume Data"| Draft
    
    Draft -->|"Raw Briefing"| Validate["dmb-validate<br/>Validate data<br/>quality & completeness"]
    
    Validate -->|"Validated Data"| Review["dmb-review-gate<br/>Add trading<br/>recommendations"]
    
    Review -->|"Enriched Briefing"| Translate["dmb-translate<br/>Translate to<br/>local languages"]
    
    Translate -->|"Localized Content"| Dispatch["dmb-dispatch<br/>Send via<br/>WhatsApp API"]
    
    Dispatch -->|"✓ Sent to"| Groups["🎯 WhatsApp Groups<br/>Malaysia<br/>Singapore<br/>Hong Kong"]
    
    Groups -->|"8:00 AM"| Teams["👥 Regional Teams<br/>Receive Briefings"]
    
    style Daily fill:#FF9800,stroke:#E65100,color:#fff
    style Orch fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Event fill:#2196F3,stroke:#1565C0,color:#fff
    style Market fill:#2196F3,stroke:#1565C0,color:#fff
    style Draft fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style Validate fill:#F44336,stroke:#C62828,color:#fff
    style Review fill:#FF5722,stroke:#D84315,color:#fff
    style Translate fill:#00BCD4,stroke:#00838F,color:#fff
    style Dispatch fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Groups fill:#FFC107,stroke:#FFA000,color:#000
    style Teams fill:#4CAF50,stroke:#2E7D32,color:#fff
```

---

## 📈 Deployment Options & Growth Path

Shows how you can scale from single server to Kubernetes and add CI/CD automation.

```mermaid
graph TD
    subgraph Now["🎯 Today: Single Server"]
        DC["Docker Compose<br/>docker-compose.yml<br/>Simple, Fast, Easy"]
    end
    
    subgraph Later["📈 Later: Multiple Servers"]
        K8s["Kubernetes<br/>kubernetes-deployment.yaml<br/>Scalable, HA, Load Balanced"]
    end
    
    subgraph Optional["🔄 Optional: Automation"]
        CI["GitLab CI/CD<br/>.gitlab-ci.yml<br/>Auto build, push, deploy"]
    end
    
    DC -->|"When you need<br/>multiple servers"| K8s
    DC -->|"When you need<br/>automation"| CI
    K8s -->|"Can also use"| CI
    
    Git["GitHub Repository<br/>aarontaii/dmb-agent"]
    Git -->|"git clone"| DC
    Git -->|"git push"| CI
    CI -->|"Builds & Deploys"| K8s
    
    style DC fill:#4CAF50,stroke:#2E7D32,color:#fff
    style K8s fill:#2196F3,stroke:#1565C0,color:#fff
    style CI fill:#FF9800,stroke:#E65100,color:#fff
    style Git fill:#000,stroke:#333,color:#fff
```

---

## 🔄 Data Flow: Sources to Teams

Shows how data flows from external sources through processing to regional teams.

```mermaid
graph LR
    subgraph Sources["📊 Data Sources"]
        TE["Trading Economics<br/>API Key"]
        Gmail["Gmail<br/>Bloomberg Emails"]
        Market["Market Data<br/>APIs"]
    end
    
    subgraph Processing["⚙️ Processing<br/>Inside Container"]
        Collect["Collect Data"]
        Parse["Parse & Extract"]
        Analyze["Analyze & Validate"]
        Enrich["Enrich with Signals"]
        Format["Format for Regions"]
    end
    
    subgraph Storage["💾 Persistent Storage<br/>Docker Volumes"]
        Events["Events Cache"]
        Data["Market Data Cache"]
        Drafts["Generated Briefings"]
        Logs["Operation Logs"]
    end
    
    subgraph Distribution["📱 Distribution"]
        WhatsApp["WhatsApp API<br/>Official Business API"]
    end
    
    subgraph Teams["👥 Regional Teams"]
        MY["🇲🇾 Malaysia<br/>Advisors Group"]
        SG["🇸🇬 Singapore<br/>Advisors Group"]
        HK["🇭🇰 Hong Kong<br/>Advisors Group"]
    end
    
    TE --> Collect
    Gmail --> Collect
    Market --> Collect
    
    Collect --> Parse
    Parse --> Analyze
    Analyze --> Enrich
    Enrich --> Format
    
    Collect -->|Cache| Events
    Analyze -->|Cache| Data
    Format -->|Save| Drafts
    Processing -->|Log All| Logs
    
    Format --> WhatsApp
    WhatsApp --> MY
    WhatsApp --> SG
    WhatsApp --> HK
    
    style Sources fill:#FF9800,stroke:#E65100,color:#fff
    style Processing fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style Storage fill:#2196F3,stroke:#1565C0,color:#fff
    style Distribution fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Teams fill:#FFC107,stroke:#FFA000,color:#000
```

---

## 🔧 Skill Management Strategy

Shows how skills are managed: from build-time bundling to three update strategies.

```mermaid
graph TD
    subgraph Image["🐳 Docker Image<br/>BUILD-TIME"]
        Build["docker build<br/>pre-installs 8 skills"]
    end
    
    subgraph Runtime["🚀 Container Runtime<br/>STARTUP"]
        Start["docker-compose up -d"]
        Step35["Step 3.5: Verify Skills<br/>Check all 8 installed"]
    end
    
    subgraph Strategies["🔄 Update Strategies"]
        Stable["Stable<br/>Rebuild quarterly<br/>Known versions"]
        Rolling["Rolling<br/>AUTO_UPDATE_SKILLS=true<br/>Always latest"]
        Manual["Manual<br/>docker exec update-all<br/>Instant update"]
    end
    
    Build -->|"All 8 skills<br/>bundled in image"| Step35
    Step35 -->|"If missing &<br/>AUTO_UPDATE=true"| Rolling
    Step35 -->|"If nothing missing"| Stable
    Step35 -->|"Anytime you need"| Manual
    
    Stable -->|"Quarterly rebuild"| Build
    Rolling -->|"Check every restart"| Start
    Manual -->|"No rebuild needed"| Manual
    
    style Image fill:#FF9800,stroke:#E65100,color:#fff
    style Runtime fill:#4CAF50,stroke:#2E7D32,color:#fff
    style Stable fill:#2196F3,stroke:#1565C0,color:#fff
    style Rolling fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style Manual fill:#F44336,stroke:#C62828,color:#fff
```

---

## 🚀 Container Startup Sequence

Shows what happens when you run `docker-compose up -d` - 5 steps to production ready.

```mermaid
graph TD
    A["docker-compose up -d<br/>Container Start"] -->|"1-3 sec"| B["Step 1: Validate<br/>Environment Variables"]
    B -->|"1 sec"| C["Step 2: Create<br/>Configuration Files"]
    C -->|"5 sec"| D["Step 3: Install<br/>& Verify Skills"]
    D -->|"5 sec"| E["Step 3.5: Check Skills ✨<br/>NEW!<br/>Verify each of 8"]
    
    E -->|"2 sec"| F["Step 4: Run Setup<br/>Validation"]
    F -->|"instant"| G["Step 5: Execute<br/>Requested Command"]
    
    G -->|"start"| G1["Scheduler Mode<br/>Runs at 5am daily"]
    G -->|"test"| G2["Test Mode<br/>Run once for verification"]
    G -->|"validate"| G3["Validation Mode<br/>Check everything"]
    
    G1 --> H["✅ Ready!<br/>Daily briefings running<br/>15-30 seconds total"]
    G2 --> H
    G3 --> H
    
    style A fill:#FFC107,stroke:#FFA000,color:#000
    style B fill:#2196F3,stroke:#1565C0,color:#fff
    style C fill:#2196F3,stroke:#1565C0,color:#fff
    style D fill:#4CAF50,stroke:#2E7D32,color:#fff
    style E fill:#FF5722,stroke:#D84315,color:#fff
    style F fill:#9C27B0,stroke:#6A1B9A,color:#fff
    style G fill:#673AB7,stroke:#4527A0,color:#fff
    style G1 fill:#4CAF50,stroke:#2E7D32,color:#fff
    style G2 fill:#4CAF50,stroke:#2E7D32,color:#fff
    style G3 fill:#4CAF50,stroke:#2E7D32,color:#fff
    style H fill:#8BC34A,stroke:#558B2F,color:#fff
```

---

## 🛡️ Production Ready Components

Shows all production-ready aspects: Docker, Monitoring, Security, and Features.

```mermaid
graph LR
    subgraph Docker["🐳 Docker Layer"]
        DockerImg["Docker Image<br/>- Multi-stage build<br/>- Skills bundled<br/>- Non-root user"]
        DockerComp["Docker Compose<br/>- Volume management<br/>- Network isolation<br/>- Auto-restart"]
    end
    
    subgraph Monitoring["📊 Monitoring"]
        Health["Health Checks<br/>- Liveness probe<br/>- Readiness probe<br/>- 5min interval"]
        Logs["Audit Logs<br/>- All operations<br/>- Timestamps<br/>- Errors captured"]
    end
    
    subgraph Security["🔐 Security"]
        Creds["Credentials<br/>- .env file<br/>- Not in git<br/>- Masked secrets"]
        Perms["Permissions<br/>- Non-root user<br/>- No privilege escalation<br/>- Minimal capabilities"]
    end
    
    subgraph Features["⚡ Features"]
        Skills["Skills<br/>- 8 coordinated<br/>- Pre-installed<br/>- Verified on start"]
        Updates["Updates<br/>- Stable strategy<br/>- Rolling strategy<br/>- Manual control"]
    end
    
    style Docker fill:#2496ED,stroke:#0066CC,color:#fff
    style Monitoring fill:#FF9800,stroke:#E65100,color:#fff
    style Security fill:#F44336,stroke:#C62828,color:#fff
    style Features fill:#4CAF50,stroke:#2E7D32,color:#fff
```

---

## 📖 Using These Diagrams

### For Team Onboarding
- Show Diagram 1 (Complete Flow) for overview
- Show Diagram 2 (Single Server) for architecture
- Show Diagram 3 (Skill Pipeline) for workflow

### For Documentation
- Add to README.md
- Reference in setup guides
- Include in technical specifications

### For Presentations
- Executive overview: Diagram 1
- Technical deep-dive: Diagrams 2-3
- Growth strategy: Diagram 4

### For Troubleshooting
- Reference Diagram 7 (Startup) when container issues
- Reference Diagram 5 (Data Flow) for data issues
- Reference Diagram 8 (Components) for architecture questions

---

## 🔗 Diagram Files

All diagrams are created using **Mermaid**, which is:
- ✅ Supported by GitHub (auto-rendered in README)
- ✅ Editable text format (in markdown)
- ✅ Version controllable (in git)
- ✅ Easy to update

To use in your own files:
1. Copy the mermaid code block
2. Paste into any `.md` file
3. GitHub auto-renders
4. Update anytime by editing markdown

---

**Version:** 1.0 | **Created:** 2026-07-31 | **Format:** Mermaid
