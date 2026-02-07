# 📋 Twitch Live Bot – DevOps Platform

Production-like DevOps setup for a self-hosted Twitch monitoring bot running on ARM-based Linux (Raspberry Pi).

This repository serves as **operational and architectural documentation** for a real-world DevOps implementation, focused on reliability, automation, and operational simplicity.

> [!NOTE]
> This repository does not contain the application source code.
> The bot itself is maintained in a separate private repository and is intentionally decoupled from infrastructure concerns.

---

## 💻 Environment

The application runs continuously (24/7) with minimal downtime and automatic recovery from failures.

**Infrastructure:**
- **Hardware:** Raspberry Pi (ARM architecture)
- **Operating System:** Raspberry Pi OS Lite (Debian-based)
- **Runtime:** Docker with Docker Compose
- **Deployment:** GitHub Actions with self-hosted runner

---

## ⚠️ Problem Statement

The system relies entirely on home infrastructure, which introduces operational challenges:

### Reliability risks
- Unstable home network connectivity
- Power outages without UPS backup
- Physical hardware constraints

### Operational overhead
- Application stops silently when failures occur
- No automatic recovery after crashes or system restarts
- Manual deployments required for every code change
- SSH access needed from multiple workstations to deploy updates

**Result:** The service required constant manual monitoring and intervention, making it unsuitable for 24/7 operation.

---

## 💡 Solution

The system was redesigned with **containerization, automated deployment, and self-recovery** to eliminate manual operations.

### Key improvements
- **Containerized runtime** ensures consistent behavior across environments
- **Automated CI/CD pipeline** eliminates manual deployments
- **Automatic restart policy** recovers from crashes without intervention
- **Persistent data management** survives container restarts
- **Self-hosted GitHub Actions runner** enables deployment from Windows workstation

---

## 🚀 Deployment Pipeline

All deployments are fully automated using GitHub Actions with a self-hosted runner.

### Workflow trigger
- Push to `main` branch
- Manual workflow dispatch

### Pipeline steps
1. **Checkout code** from GitHub repository
2. **Deploy via SSH** to Raspberry Pi using key-based authentication
3. **Stop existing containers** gracefully with `docker-compose down`
4. **Transfer application files** (Dockerfile, source code, dependencies, database schema)
5. **Build Docker image** for ARM architecture
6. **Start containers** with `docker-compose up -d --build`
7. **Verify deployment** by checking container status

![Deployment Flow](/diagrams/deployment_flow.jpg)

### Deployment guarantees
- Zero manual SSH usage required
- Consistent deployments from any workstation
- Fast recovery after failures (container restarts automatically)
- Atomic deployments with rollback capability via Git history

---

## 🏗️ Runtime Architecture

The application runs as a single Docker container on self-hosted ARM hardware.

### Components
- **Discord Bot** (Python): Monitors Twitch API and sends Discord notifications
- **SQLite Database**: Stores channel subscriptions and bot state (persisted via Docker volume)
- **Flask HTTP Server**: Exposes basic status endpoint on port 5000
- **Docker Engine**: Provides process isolation and automatic restart

### External dependencies
- **Twitch Helix API**: Polled periodically for live stream status
- **Discord API**: Used for sending notifications and handling commands
- **GitHub Actions**: Triggers automated deployments

### Persistence strategy
- Database file stored in `/data` volume mount
- Volume persists across container restarts
- Survives host reboots and container rebuilds

![Architecture Diagram](/diagrams/architecture.jpg)

---

## 🧠 Design Rationale

This architecture intentionally prioritizes **simplicity and reliability** over scalability.

### Why this approach works
- **Eliminates manual deployments** → Push to `main` triggers automatic rollout
- **Ensures automatic recovery** → Container restarts on crashes or host reboot
- **Reduces operational overhead** → No database servers or orchestration platforms to manage
- **Maintains observability** → Docker logs provide deployment and runtime visibility

### What was intentionally avoided
- Kubernetes or container orchestration (overkill for single-node setup)
- External database services (adds complexity and failure points)
- Webhook-based deployments (polling is simpler and more reliable for this scale)
- Cloud hosting (intentional constraint for home infrastructure use case)

---

## ⚖️ Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Docker over systemd** | Predictable runtime environment, easier dependency management, portable across ARM/x86 |
| **SQLite over external DB** | Zero operational overhead, sufficient for low-volume workload, eliminates network dependency |
| **Polling over webhooks** | Simpler to implement and debug, no firewall/NAT configuration required |
| **SSH-based deployment** | Appropriate for single-node environments, leverages existing infrastructure |
| **Self-hosted runner** | Enables deployment from Windows workstation, avoids exposing Pi to internet |
| **No orchestration platform** | Kubernetes/Nomad would add unnecessary complexity for single-container workload |

---

## 📊 Results

### Reliability improvements
- **Uptime:** ~stable 99% (limited only by internet/power outages)
- **Recovery time:** < 30 seconds after crashes (automatic restart)
- **Deployment:** Simplified, now automated
- **Manual intervention:** Reduced to zero under normal operation

### Operational metrics
- **Deployment time:** ~2 minutes from push to production
- **Failed deployments:** Visible in GitHub Actions, easy to rollback via Git
- **Resource usage:** < 200MB RAM, negligible CPU when idle

---

## 🔄 Current Limitations & Future Work

### Known limitations
1. **No health check verification** in deployment pipeline (currently only checks container status)
2. **No alerting** for application failures or API rate limits
3. **No metrics collection** or performance monitoring
4. **Single point of failure** (no redundancy for hardware or network failures)

### Planned improvements
- [ ] Implement proper health check endpoint verification in CI/CD pipeline
- [ ] Add uptime monitoring with [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [ ] Set up log aggregation for easier debugging
- [ ] Add basic metrics dashboard (Prometheus + Grafana or similar)
- [ ] Implement deployment notifications (Discord webhook on success/failure)

---

## 🛠️ Technologies Used

| Category | Technology |
|----------|------------|
| **Application** | Python, Flask, Discord.py |
| **Containerization** | Docker, Docker Compose |
| **CI/CD** | GitHub Actions (self-hosted runner on Windows) |
| **Infrastructure** | Raspberry Pi OS Lite, ARM64 architecture |
| **Data** | SQLite with Docker volume persistence |
| **Deployment** | SSH with key-based authentication, PowerShell automation |

---

## 📂 Repository Structure

```
├── diagrams/
│   └── deployment_flow.jpg      # Visual deployment workflow
├── .github/
│   └── workflows/
│       └── deploy.yml            # GitHub Actions deployment pipeline
├── docker-compose.yml            # Container orchestration config
├── Dockerfile                    # Container image definition
└── README.md                     # This file
```

> [!NOTE]
> Application source code (`src/`), dependencies (`requirements.txt`), database schema (`schema.sql`), and environment variables (`.env`) are maintained in the private application repository and deployed via CI/CD.

---

## 🎯 Key Takeaways

This project demonstrates:
- **Operational thinking** – Solving real reliability problems with automation
- **Appropriate technology choices** – Matching solutions to constraints
- **DevOps fundamentals** – CI/CD, containerization, infrastructure as code principles
- **Self-hosted infrastructure** – Managing bare-metal systems with limited resources

The architecture is intentionally simple, avoiding over-engineering while still applying production-grade DevOps practices.
