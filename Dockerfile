# DMB Agent Docker Image
# Multi-stage build with dynamic skill updates
#
# This Dockerfile:
# 1. Bundles all skills at build time (fast startup)
# 2. Validates skills at runtime (ensures freshness)
# 3. Auto-updates skills if environment variable set
#
# Build: docker build -t dmb-agent:latest .
# Run:   docker run -e AUTO_UPDATE_SKILLS=true dmb-agent:latest

FROM ubuntu:22.04 as base

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    jq \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaw CLI
RUN curl -L https://openclaw.dev/install.sh | bash && \
    openclaw --version

# Set working directory
WORKDIR /app

# Copy the DMB Agent code (skills + config)
COPY . /app/

################################################################################
# STAGE 1: Bundle OpenClaw Skills at Build Time
################################################################################

# Pre-install all 8 DMB skills
RUN echo "Installing OpenClaw skills..." && \
    openclaw install /app/skills/dmb-orchestrator && \
    openclaw install /app/skills/dmb-macro-events && \
    openclaw install /app/skills/dmb-draft && \
    openclaw install /app/skills/dmb-market-data && \
    openclaw install /app/skills/dmb-validate && \
    openclaw install /app/skills/dmb-review-gate && \
    openclaw install /app/skills/dmb-translate && \
    openclaw install /app/skills/dmb-dispatch && \
    echo "✓ All skills installed"

# Verify skills installed
RUN echo "Verifying skills..." && \
    openclaw skills list | grep -c "dmb-" | grep -q "8" && \
    echo "✓ All 8 skills verified"

################################################################################
# STAGE 2: Final Production Image
################################################################################

FROM base

# Create non-root user
RUN useradd -m -u 1000 openclaw && \
    chown -R openclaw:openclaw /app

USER openclaw

# Copy entrypoint script
COPY --chown=openclaw:openclaw docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Copy skill update script
COPY --chown=openclaw:openclaw docker-skill-updater.sh /app/
RUN chmod +x /app/docker-skill-updater.sh

# Create state and log directories
RUN mkdir -p /app/state/{drafts,events,marketdata,holidays} && \
    mkdir -p /app/logs

# Metadata about skills bundled
ENV BUNDLED_SKILLS_VERSION="1.0" \
    BUNDLED_SKILLS_DATE="2026-07-31" \
    BUNDLED_SKILLS_COUNT="8"

# Environment variables
ENV AUTO_UPDATE_SKILLS="false" \
    CHECK_SKILLS_ON_START="true" \
    LOG_LEVEL="INFO"

# Health check - verify skills are still installed
HEALTHCHECK --interval=5m --timeout=30s --start-period=30s --retries=3 \
    CMD openclaw skills list | grep -q "dmb-orchestrator" && \
    openclaw dmb-orchestrator --status --date $(date +%Y-%m-%d) || exit 1

# Default entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["start"]

# Labels
LABEL maintainer="DMB Team"
LABEL description="iFAST Daily Market Brew Agent - Docker Image"
LABEL version="1.0"
LABEL skills="dmb-orchestrator,dmb-macro-events,dmb-draft,dmb-market-data,dmb-validate,dmb-review-gate,dmb-translate,dmb-dispatch"
