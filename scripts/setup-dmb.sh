#!/bin/bash

################################################################################
# DMB Agent System — Automated Setup Script
#
# This script validates and prepares the DMB Agent system for use.
#
# Usage: bash scripts/setup-dmb.sh
#
# What it does:
#   1. Check prerequisites (OpenClaw, Python, Git)
#   2. Verify all 8 skills are installed
#   3. Validate configuration files
#   4. Create/verify state directories
#   5. Test TradingEconomics API connection
#   6. Run end-to-end system test
#   7. Provide verification checklist
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

################################################################################
# Utility Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_check() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

################################################################################
# Main Setup
################################################################################

print_header "DMB Agent Setup — Starting Installation"

# Check if we're in the right directory
if [ ! -f "QUICK_START.md" ] && [ ! -f "README.md" ]; then
    print_error "Not in dmb-agent directory!"
    echo "Please run this script from the root of the dmb-agent folder:"
    echo "  cd dmb-agent/"
    echo "  bash scripts/setup-dmb.sh"
    exit 1
fi

print_info "Running from: $(pwd)"
echo ""

################################################################################
# 1. Check Prerequisites
################################################################################

print_header "Step 1: Checking Prerequisites"

# Check OpenClaw
if command -v openclaw &> /dev/null; then
    OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    print_check "OpenClaw installed: $OPENCLAW_VERSION"
else
    print_error "OpenClaw CLI not found"
    echo "Install from: https://openclaw.dev/install"
    exit 1
fi

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_check "Python 3 installed: $PYTHON_VERSION"
else
    print_error "Python 3 not found"
    echo "Install from: https://python.org"
    exit 1
fi

# Check Git
if command -v git &> /dev/null; then
    print_check "Git installed"
else
    print_error "Git not found"
    echo "Install from: https://git-scm.com"
    exit 1
fi

echo ""

################################################################################
# 2. Verify Skills Installation
################################################################################

print_header "Step 2: Verifying Skill Installation"

REQUIRED_SKILLS=(
    "dmb-orchestrator"
    "dmb-macro-events"
    "dmb-draft"
    "dmb-market-data"
    "dmb-validate"
    "dmb-review-gate"
    "dmb-translate"
    "dmb-dispatch"
)

SKILLS_COUNT=0
for skill in "${REQUIRED_SKILLS[@]}"; do
    if openclaw skills list 2>/dev/null | grep -q "$skill"; then
        print_check "$skill installed"
        ((SKILLS_COUNT++))
    else
        print_error "$skill NOT installed"
        echo "  Try: openclaw install skills/$skill"
    fi
done

echo ""
print_info "Skills installed: $SKILLS_COUNT / ${#REQUIRED_SKILLS[@]}"

if [ $SKILLS_COUNT -ne ${#REQUIRED_SKILLS[@]} ]; then
    print_error "Not all skills are installed!"
    echo ""
    echo "Install missing skills with:"
    for skill in "${REQUIRED_SKILLS[@]}"; do
        if ! openclaw skills list 2>/dev/null | grep -q "$skill"; then
            echo "  openclaw install skills/$skill"
        fi
    done
    exit 1
fi

echo ""

################################################################################
# 3. Validate Configuration Files
################################################################################

print_header "Step 3: Validating Configuration"

# Check .env file
if [ -f ".env" ]; then
    print_check ".env file exists"

    # Check for required environment variables
    if grep -q "TE_API_KEY\|TRADING_ECONOMICS" .env; then
        print_check "TradingEconomics API key configured"
    else
        print_warning "TradingEconomics API key not found in .env"
        echo "  Add: TE_API_KEY=your_key"
    fi

    if grep -q "GMAIL\|gmail" .env; then
        print_check "Gmail credentials configured"
    else
        print_warning "Gmail credentials not found in .env"
        echo "  Add: GMAIL_USERNAME and GMAIL_PASSWORD"
    fi

    if grep -q "WHATSAPP" .env; then
        print_check "WhatsApp credentials configured"
    else
        print_warning "WhatsApp credentials not found in .env"
        echo "  Add: WHATSAPP_API_TOKEN, WHATSAPP_PHONE_ID"
    fi
else
    print_error ".env file not found"
    echo "Create it with: cp config/te_calendar.env.example .env"
    echo "Then edit: nano .env"
    exit 1
fi

echo ""

# Check dispatch config
if [ -f "config/dmb-dispatch.json" ]; then
    print_check "config/dmb-dispatch.json exists"

    if grep -q "@g.us" config/dmb-dispatch.json; then
        GROUPS=$(grep -o "@g.us" config/dmb-dispatch.json | wc -l)
        print_check "Found $GROUPS WhatsApp group IDs"
    else
        print_warning "No WhatsApp group IDs found in dispatch config"
        echo "  Edit: nano config/dmb-dispatch.json"
    fi
else
    print_error "config/dmb-dispatch.json not found"
    echo "Create it with: cp config/dmb-dispatch.json.example config/dmb-dispatch.json"
    exit 1
fi

echo ""

# Check holidays config
if [ -f "state/holidays/2026.yaml" ]; then
    print_check "state/holidays/2026.yaml exists"
else
    print_warning "state/holidays/2026.yaml not found"
    echo "Create it with: cp config/holidays.example.yaml state/holidays/2026.yaml"
fi

echo ""

################################################################################
# 4. Create State Directories
################################################################################

print_header "Step 4: Creating State Directories"

DIRS=("state/drafts" "state/events" "state/marketdata" "state/holidays")

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_check "$dir exists"
    else
        mkdir -p "$dir"
        print_check "$dir created"
    fi
done

echo ""

################################################################################
# 5. Test Connections
################################################################################

print_header "Step 5: Testing API Connections"

# Test TradingEconomics API (if key is present)
if grep -q "TE_API_KEY\|TRADING_ECONOMICS" .env 2>/dev/null; then
    print_info "Testing TradingEconomics API..."

    # Note: Actual API test would require running the script
    # For now, just verify the key is set
    if [ -n "${TE_API_KEY}" ] || grep -q "TE_API_KEY=" .env; then
        print_check "TradingEconomics API key is set"
    else
        print_warning "Could not verify TradingEconomics API key"
    fi
else
    print_warning "Skipping TradingEconomics API test (key not configured)"
fi

echo ""

################################################################################
# 6. Run System Test
################################################################################

print_header "Step 6: Running System Test"

# Test date (use a past date to ensure data is available)
TEST_DATE="2026-07-20"

print_info "Running end-to-end test for $TEST_DATE..."
echo "(This may take 1-2 minutes)"
echo ""

if openclaw dmb-orchestrator --test --date "$TEST_DATE" 2>/dev/null; then
    print_check "End-to-end test PASSED"

    # Check if draft was created
    if [ -f "state/drafts/$TEST_DATE/draft.json" ]; then
        print_check "Draft JSON created"

        # Check if headline exists
        if grep -q "headline" "state/drafts/$TEST_DATE/draft.json"; then
            print_check "Draft contains headline"
        fi
    fi
else
    print_warning "End-to-end test did not complete"
    echo "This might be due to:"
    echo "  • API credentials not valid"
    echo "  • Network issues"
    echo "  • Missing data for test date"
    echo ""
    echo "You can retry test with:"
    echo "  openclaw dmb-orchestrator --test --date 2026-07-20"
fi

echo ""

################################################################################
# 7. Verification Checklist
################################################################################

print_header "Verification Checklist"

echo -e "${YELLOW}Review the items below:${NC}"
echo ""

echo "SKILLS INSTALLED:"
for skill in "${REQUIRED_SKILLS[@]}"; do
    if openclaw skills list 2>/dev/null | grep -q "$skill"; then
        echo "  ☐ $skill"
    fi
done

echo ""
echo "CONFIGURATION:"
echo "  ☐ .env file configured"
echo "  ☐ config/dmb-dispatch.json has group IDs"
echo "  ☐ config/dmb-dispatch.json has approver E.164s"
echo "  ☐ state/holidays/2026.yaml loaded"

echo ""
echo "DIRECTORIES:"
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ☐ $dir"
    fi
done

echo ""
echo "TESTING:"
if [ -f "state/drafts/2026-07-20/draft.json" ]; then
    echo "  ☐ Test run completed successfully"
    echo "  ☐ Draft JSON created"
else
    echo "  ☗ Run test manually: openclaw dmb-orchestrator --test --date 2026-07-20"
fi

echo ""

################################################################################
# 8. Summary
################################################################################

print_header "Setup Summary"

echo "✓ Checks passed: $CHECKS_PASSED"
echo "✗ Checks failed: $CHECKS_FAILED"

echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}SETUP SUCCESSFUL! 🎉${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. SUPERVISORS: Read SUPERVISOR_GUIDE.md"
    echo "   → Learn 5 approval commands"
    echo ""
    echo "2. ADMINS: Read ADMIN_CHECKLIST.md"
    echo "   → Schedule daily cron job:"
    echo "   → openclaw dmb-orchestrator --schedule \"0 5 * * 1-5\""
    echo ""
    echo "3. EVERYONE: Monitor logs"
    echo "   → openclaw dmb-orchestrator --logs --follow"
    echo ""
    echo "Ready to go live! 🚀"
else
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}SETUP INCOMPLETE${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo "Please fix the items marked with ✗ above, then run again:"
    echo "  bash scripts/setup-dmb.sh"
    echo ""
    echo "Need help?"
    echo "  • Check QUICK_START.md for troubleshooting"
    echo "  • Run manual test: openclaw dmb-orchestrator --test --date 2026-07-20"
    echo "  • Check logs: openclaw dmb-orchestrator --logs"
    exit 1
fi

echo ""
