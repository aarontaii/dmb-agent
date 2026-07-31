#!/bin/bash

################################################################################
# DMB Agent Docker Entrypoint
#
# This script:
# 1. Validates all required environment variables
# 2. Creates configuration from environment variables
# 3. Installs OpenClaw skills
# 4. Runs setup validation
# 5. Executes the requested command
#
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

################################################################################
# Step 1: Validate Environment Variables
################################################################################

print_header "Step 1: Validating Environment Variables"

REQUIRED_VARS=(
    "TRADING_ECONOMICS_API_KEY"
    "GMAIL_USERNAME"
    "GMAIL_PASSWORD"
    "WHATSAPP_API_TOKEN"
    "WHATSAPP_PHONE_ID"
    "DMB_DISPATCH_GROUPS"
)

MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
        print_error "Missing: $var"
    else
        print_success "Found: $var"
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo ""
    print_error "Missing environment variables: ${MISSING_VARS[@]}"
    exit 1
fi

print_success "All required environment variables present"
echo ""

################################################################################
# Step 2: Create Configuration Files
################################################################################

print_header "Step 2: Creating Configuration Files"

# Create .env file
cat > /app/.env << EOF
TRADING_ECONOMICS_API_KEY=${TRADING_ECONOMICS_API_KEY}
TE_API_KEY=${TRADING_ECONOMICS_API_KEY}
GMAIL_USERNAME=${GMAIL_USERNAME}
GMAIL_PASSWORD=${GMAIL_PASSWORD}
WHATSAPP_API_TOKEN=${WHATSAPP_API_TOKEN}
WHATSAPP_PHONE_ID=${WHATSAPP_PHONE_ID}
LOG_LEVEL=${LOG_LEVEL:-INFO}
DEBUG=${DEBUG:-false}
EOF

print_success "Created .env file"

# Parse dispatch groups (format: "MY:groupid1 SG:groupid2 HK:groupid3")
# Example: "MY:123456789-1234567890@g.us SG:987654321-9876543210@g.us"

cat > /app/config/dmb-dispatch.json << 'EOF'
{
  "regions": {
    "MY": {
      "group_id": "PLACEHOLDER",
      "name": "iFAST Malaysia Advisors",
      "approvers": []
    },
    "SG": {
      "group_id": "PLACEHOLDER",
      "name": "iFAST Singapore Advisors",
      "approvers": []
    },
    "HK": {
      "group_id": "PLACEHOLDER",
      "name": "iFAST Hong Kong Advisors",
      "approvers": []
    }
  },
  "working_group_id": "PLACEHOLDER",
  "working_group_name": "DMB Research Team"
}
EOF

# Parse dispatch groups JSON from environment
if [ -n "${DMB_DISPATCH_GROUPS_JSON}" ]; then
    echo "${DMB_DISPATCH_GROUPS_JSON}" > /app/config/dmb-dispatch.json
    print_success "Configured dispatch groups from JSON"
else
    print_warning "DMB_DISPATCH_GROUPS_JSON not provided, using placeholder config"
fi

# Create or update holidays
if [ -n "${DMB_HOLIDAYS_YAML}" ]; then
    echo "${DMB_HOLIDAYS_YAML}" > /app/state/holidays/2026.yaml
    print_success "Configured market holidays"
else
    print_warning "DMB_HOLIDAYS_YAML not provided, using empty holidays"
    touch /app/state/holidays/2026.yaml
fi

echo ""

################################################################################
# Step 3: Install OpenClaw Skills
################################################################################

print_header "Step 3: Installing OpenClaw Skills"

SKILLS=(
    "dmb-orchestrator"
    "dmb-macro-events"
    "dmb-draft"
    "dmb-market-data"
    "dmb-validate"
    "dmb-review-gate"
    "dmb-translate"
    "dmb-dispatch"
)

for skill in "${SKILLS[@]}"; do
    echo "Installing $skill..."
    openclaw install /app/skills/$skill 2>/dev/null || print_warning "$skill may already be installed"
done

print_success "Skills installation complete"
echo ""

################################################################################
# Step 3.5: Check Skills (Optional Auto-Update)
################################################################################

CHECK_SKILLS_ON_START=${CHECK_SKILLS_ON_START:-true}
AUTO_UPDATE_SKILLS=${AUTO_UPDATE_SKILLS:-false}

if [ "$CHECK_SKILLS_ON_START" = "true" ]; then
    print_header "Step 3.5: Checking Installed Skills"

    SKILLS_OK=true
    for skill in "${SKILLS[@]}"; do
        if openclaw skills list 2>/dev/null | grep -q "$skill"; then
            print_success "Verified: $skill"
        else
            print_warning "Missing: $skill"
            SKILLS_OK=false
        fi
    done

    if [ "$SKILLS_OK" = "false" ] && [ "$AUTO_UPDATE_SKILLS" = "true" ]; then
        print_warning "Some skills missing, updating..."
        for skill in "${SKILLS[@]}"; do
            if ! openclaw skills list 2>/dev/null | grep -q "$skill"; then
                echo "Installing missing skill: $skill"
                openclaw install /app/skills/$skill 2>/dev/null || print_warning "Could not install $skill"
            fi
        done
        print_success "Skill update check complete"
    fi

    echo ""
fi

################################################################################
# Step 4: Run Setup Validation
################################################################################

print_header "Step 4: Running Setup Validation"

if [ -f "/app/scripts/setup-dmb.sh" ]; then
    bash /app/scripts/setup-dmb.sh
    print_success "Setup validation complete"
else
    print_warning "Setup script not found, skipping validation"
fi

echo ""

################################################################################
# Step 5: Execute Command
################################################################################

print_header "Step 5: Executing Command"

COMMAND=${1:-start}

case $COMMAND in
    start)
        echo "Starting DMB Agent scheduler..."
        openclaw dmb-orchestrator --schedule "0 5 * * 1-5"
        echo "Scheduler started. Monitoring logs..."
        openclaw dmb-orchestrator --logs --follow
        ;;

    test)
        echo "Running test..."
        TEST_DATE=${2:-2026-07-20}
        openclaw dmb-orchestrator --test --date $TEST_DATE
        ;;

    run)
        echo "Running orchestrator once..."
        openclaw dmb-orchestrator --run --now
        ;;

    logs)
        echo "Streaming logs..."
        openclaw dmb-orchestrator --logs --follow
        ;;

    status)
        echo "Checking status..."
        TARGET_DATE=${2:-$(date +%Y-%m-%d)}
        openclaw dmb-orchestrator --status --date $TARGET_DATE
        ;;

    validate)
        echo "Validating setup..."
        bash /app/scripts/setup-dmb.sh
        ;;

    shell)
        echo "Launching interactive shell..."
        /bin/bash
        ;;

    *)
        print_error "Unknown command: $COMMAND"
        echo ""
        echo "Available commands:"
        echo "  start      - Start scheduler and stream logs (default)"
        echo "  test       - Run end-to-end test [date]"
        echo "  run        - Run orchestrator once"
        echo "  logs       - Stream logs"
        echo "  status     - Check status [date]"
        echo "  validate   - Run setup validation"
        echo "  shell      - Launch interactive shell"
        exit 1
        ;;
esac
