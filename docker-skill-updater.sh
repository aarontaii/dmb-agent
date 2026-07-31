#!/bin/bash
#
# Docker Skill Updater Script
# Automatically updates OpenClaw skills in the Docker container
#
# Features:
# - Checks for new versions of skills
# - Updates skills if newer versions available
# - Validates skills after update
# - Logs all operations
#
# Usage:
# ./docker-skill-updater.sh        # Update all skills
# ./docker-skill-updater.sh skill-name  # Update specific skill
#
# Environment variables:
# - AUTO_UPDATE_SKILLS: "true" to auto-update on startup (default: false)
# - SKILL_UPDATE_LOG: Path to log file (default: /app/logs/skill-updates.log)

set -e

################################################################################
# CONFIGURATION
################################################################################

SKILL_UPDATE_LOG="${SKILL_UPDATE_LOG:-/app/logs/skill-updates.log}"
AUTO_UPDATE_SKILLS="${AUTO_UPDATE_SKILLS:-false}"
SKILLS_DIR="${SKILLS_DIR:-/app/skills}"

# All 8 DMB skills
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

################################################################################
# FUNCTIONS
################################################################################

log() {
    local level=$1
    shift
    local msg="$@"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $msg" | tee -a "$SKILL_UPDATE_LOG"
}

log_header() {
    echo "" | tee -a "$SKILL_UPDATE_LOG"
    echo "================================================================================" | tee -a "$SKILL_UPDATE_LOG"
    echo "  $@" | tee -a "$SKILL_UPDATE_LOG"
    echo "================================================================================" | tee -a "$SKILL_UPDATE_LOG"
}

check_openclaw() {
    log "INFO" "Checking OpenClaw CLI..."
    if ! command -v openclaw &> /dev/null; then
        log "ERROR" "OpenClaw CLI not found in PATH"
        return 1
    fi
    local version=$(openclaw --version 2>&1 || echo "unknown")
    log "INFO" "OpenClaw version: $version"
    return 0
}

check_skill_version() {
    local skill=$1
    log "DEBUG" "Checking version for skill: $skill"

    # Check if skill is installed
    if openclaw skills list 2>/dev/null | grep -q "$skill"; then
        log "INFO" "Skill installed: $skill"
        return 0
    else
        log "WARN" "Skill NOT installed: $skill"
        return 1
    fi
}

update_skill() {
    local skill=$1
    local skill_path="${SKILLS_DIR}/${skill}"

    log "INFO" "Updating skill: $skill"

    # Check if skill directory exists
    if [ ! -d "$skill_path" ]; then
        log "WARN" "Skill directory not found: $skill_path"
        log "INFO" "Installing skill from remote..."
        if openclaw install "$skill"; then
            log "INFO" "✓ Skill installed successfully: $skill"
            return 0
        else
            log "ERROR" "Failed to install skill: $skill"
            return 1
        fi
    fi

    # Update from local directory
    if openclaw install "$skill_path"; then
        log "INFO" "✓ Skill updated successfully: $skill"
        return 0
    else
        log "ERROR" "Failed to update skill: $skill"
        return 1
    fi
}

validate_skill() {
    local skill=$1
    log "DEBUG" "Validating skill: $skill"

    if openclaw skills list 2>/dev/null | grep -q "$skill"; then
        log "INFO" "✓ Skill validated: $skill"
        return 0
    else
        log "ERROR" "✗ Skill validation failed: $skill"
        return 1
    fi
}

update_all_skills() {
    log_header "Updating All DMB Skills"

    local updated=0
    local failed=0

    for skill in "${SKILLS[@]}"; do
        if update_skill "$skill"; then
            if validate_skill "$skill"; then
                ((updated++))
                log "INFO" "✓ $skill: success"
            else
                ((failed++))
                log "WARN" "$skill: validation failed"
            fi
        else
            ((failed++))
            log "ERROR" "✗ $skill: update failed"
        fi
    done

    log "" ""
    log "INFO" "Skills update summary:"
    log "INFO" "  Updated: $updated/${#SKILLS[@]}"
    log "INFO" "  Failed:  $failed/${#SKILLS[@]}"

    if [ $failed -eq 0 ]; then
        log "INFO" "✓ All skills updated successfully"
        return 0
    else
        log "WARN" "Some skills failed to update"
        return 1
    fi
}

update_specific_skill() {
    local skill=$1

    log_header "Updating Specific Skill: $skill"

    # Validate skill name
    local found=0
    for s in "${SKILLS[@]}"; do
        if [ "$s" == "$skill" ]; then
            found=1
            break
        fi
    done

    if [ $found -eq 0 ]; then
        log "ERROR" "Unknown skill: $skill"
        log "INFO" "Available skills:"
        for s in "${SKILLS[@]}"; do
            log "INFO" "  - $s"
        done
        return 1
    fi

    if update_skill "$skill"; then
        if validate_skill "$skill"; then
            log "INFO" "✓ Skill updated successfully: $skill"
            return 0
        else
            log "WARN" "Skill validation failed: $skill"
            return 1
        fi
    else
        log "ERROR" "Failed to update skill: $skill"
        return 1
    fi
}

check_all_skills() {
    log_header "Checking All DMB Skills"

    local installed=0
    local missing=0

    for skill in "${SKILLS[@]}"; do
        if check_skill_version "$skill"; then
            ((installed++))
        else
            ((missing++))
        fi
    done

    log "" ""
    log "INFO" "Skills status:"
    log "INFO" "  Installed: $installed/${#SKILLS[@]}"
    log "INFO" "  Missing:   $missing/${#SKILLS[@]}"

    if [ $missing -gt 0 ]; then
        log "WARN" "Some skills are missing"
        return 1
    else
        log "INFO" "✓ All skills are installed"
        return 0
    fi
}

show_usage() {
    cat << EOF
Docker Skill Updater Script

USAGE:
    docker-skill-updater.sh [COMMAND] [OPTIONS]

COMMANDS:
    update-all              Update all 8 DMB skills (default)
    update SKILL_NAME       Update specific skill
    check-all               Check status of all skills
    check SKILL_NAME        Check specific skill status
    list                    List all available skills
    help                    Show this help message

EXAMPLES:
    # Update all skills
    ./docker-skill-updater.sh update-all

    # Update specific skill
    ./docker-skill-updater.sh update dmb-orchestrator

    # Check all skills
    ./docker-skill-updater.sh check-all

    # List available skills
    ./docker-skill-updater.sh list

ENVIRONMENT VARIABLES:
    AUTO_UPDATE_SKILLS      Set to "true" to auto-update on startup
    SKILL_UPDATE_LOG        Path to log file (default: /app/logs/skill-updates.log)
    SKILLS_DIR              Path to skills directory (default: /app/skills)

AUTO-UPDATE ON STARTUP:
    To auto-update skills when container starts, set:
    docker run -e AUTO_UPDATE_SKILLS=true dmb-agent:latest start

LOGS:
    Update logs are stored in: $SKILL_UPDATE_LOG
    View logs:
    docker exec dmb-agent tail -f /app/logs/skill-updates.log

EOF
}

################################################################################
# MAIN
################################################################################

main() {
    # Create log directory if needed
    mkdir -p "$(dirname "$SKILL_UPDATE_LOG")"

    log_header "DMB Agent Skill Updater"
    log "INFO" "Started at $(date)"
    log "INFO" "Log file: $SKILL_UPDATE_LOG"

    # Check OpenClaw
    if ! check_openclaw; then
        log "ERROR" "OpenClaw CLI is not available"
        exit 1
    fi

    # Parse command
    local command=${1:-update-all}

    case "$command" in
        update-all)
            update_all_skills
            exit $?
            ;;
        update)
            if [ -z "$2" ]; then
                log "ERROR" "Skill name required"
                echo ""
                show_usage
                exit 1
            fi
            update_specific_skill "$2"
            exit $?
            ;;
        check-all)
            check_all_skills
            exit $?
            ;;
        check)
            if [ -z "$2" ]; then
                log "ERROR" "Skill name required"
                echo ""
                show_usage
                exit 1
            fi
            check_skill_version "$2"
            exit $?
            ;;
        list)
            echo "Available DMB Skills:"
            for skill in "${SKILLS[@]}"; do
                echo "  - $skill"
            done
            exit 0
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            log "ERROR" "Unknown command: $command"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
