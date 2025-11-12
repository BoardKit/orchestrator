#!/bin/bash

# Validate Setup Script
# Validates that orchestrator setup completed successfully
#
# Usage: ./setup/scripts/validate-setup.sh
# Run from orchestrator root directory

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory and orchestrator root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$ORCHESTRATOR_ROOT/SETUP_CONFIG.json"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Check result function
check_result() {
    local name="$1"
    local status="$2"
    local message="$3"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ "$status" = "pass" ]; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif [ "$status" = "fail" ]; then
        echo -e "${RED}✗${NC} $name"
        if [ -n "$message" ]; then
            echo -e "  ${RED}→${NC} $message"
        fi
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}⚠${NC} $name"
        if [ -n "$message" ]; then
            echo -e "  ${YELLOW}→${NC} $message"
        fi
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Orchestrator Setup Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check 1: jq installed
echo -e "${CYAN}Checking Prerequisites...${NC}"
if command -v jq &> /dev/null; then
    check_result "jq is installed" "pass"
else
    check_result "jq is installed" "fail" "Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)"
fi
echo ""

# Check 2: SETUP_CONFIG.json exists
echo -e "${CYAN}Checking Configuration...${NC}"
if [ -f "$CONFIG_FILE" ]; then
    check_result "SETUP_CONFIG.json exists" "pass"

    # Check 3: Valid JSON
    if jq empty "$CONFIG_FILE" 2>/dev/null; then
        check_result "SETUP_CONFIG.json is valid JSON" "pass"

        # Get config values
        ORG_NAME=$(jq -r '.organization.name' "$CONFIG_FILE")
        REPO_COUNT=$(jq '.repositories | length' "$CONFIG_FILE")

        echo -e "  ${CYAN}→${NC} Organization: $ORG_NAME"
        echo -e "  ${CYAN}→${NC} Repositories: $REPO_COUNT"
    else
        check_result "SETUP_CONFIG.json is valid JSON" "fail" "File contains invalid JSON"
    fi
else
    check_result "SETUP_CONFIG.json exists" "fail" "Run setup wizard: /setup-orchestrator"
fi
echo ""

# Check 4: CLAUDE.md
echo -e "${CYAN}Checking Generated Files...${NC}"
if [ -f "$ORCHESTRATOR_ROOT/CLAUDE.md" ]; then
    check_result "CLAUDE.md exists" "pass"

    # Check for placeholders
    if grep -q "{{.*}}" "$ORCHESTRATOR_ROOT/CLAUDE.md"; then
        check_result "CLAUDE.md has no placeholders" "fail" "Found unreplaced {{PLACEHOLDERS}}"
    else
        check_result "CLAUDE.md has no placeholders" "pass"
    fi
else
    check_result "CLAUDE.md exists" "fail" "File not generated"
fi

# Check 5: README.md
if [ -f "$ORCHESTRATOR_ROOT/README.md" ]; then
    check_result "README.md exists" "pass"

    # Check for placeholders
    if grep -q "{{.*}}" "$ORCHESTRATOR_ROOT/README.md"; then
        check_result "README.md has no placeholders" "fail" "Found unreplaced {{PLACEHOLDERS}}"
    else
        check_result "README.md has no placeholders" "pass"
    fi
else
    check_result "README.md exists" "fail" "File not generated"
fi
echo ""

# Check 6: skill-rules.json
echo -e "${CYAN}Checking Skills Configuration...${NC}"
SKILL_RULES="$ORCHESTRATOR_ROOT/shared/skills/skill-rules.json"
if [ -f "$SKILL_RULES" ]; then
    check_result "skill-rules.json exists" "pass"

    # Check valid JSON
    if jq empty "$SKILL_RULES" 2>/dev/null; then
        check_result "skill-rules.json is valid JSON" "pass"

        # Count skills
        SKILL_COUNT=$(jq '.skills | length' "$SKILL_RULES")
        echo -e "  ${CYAN}→${NC} Skills configured: $SKILL_COUNT"
    else
        check_result "skill-rules.json is valid JSON" "fail" "File contains invalid JSON"
    fi
else
    check_result "skill-rules.json exists" "fail" "File not generated"
fi
echo ""

# Check 7: Repository skills
if [ -f "$CONFIG_FILE" ] && command -v jq &> /dev/null; then
    echo -e "${CYAN}Checking Repository Skills...${NC}"

    REPO_COUNT=$(jq '.repositories | length' "$CONFIG_FILE")
    for i in $(seq 0 $((REPO_COUNT - 1))); do
        REPO_NAME=$(jq -r ".repositories[$i].name" "$CONFIG_FILE")
        SKILL_DIR="$ORCHESTRATOR_ROOT/shared/skills/${REPO_NAME}-guidelines"

        if [ -d "$SKILL_DIR" ]; then
            check_result "Skill directory exists: ${REPO_NAME}-guidelines" "pass"

            # Check skill.md
            if [ -f "$SKILL_DIR/skill.md" ]; then
                check_result "  skill.md exists for $REPO_NAME" "pass"

                # Check for placeholders
                if grep -q "{{.*}}" "$SKILL_DIR/skill.md"; then
                    check_result "  skill.md has no placeholders" "fail" "Found unreplaced {{PLACEHOLDERS}}"
                else
                    check_result "  skill.md has no placeholders" "pass"
                fi
            else
                check_result "  skill.md exists for $REPO_NAME" "fail"
            fi

            # Check README.md
            if [ -f "$SKILL_DIR/README.md" ]; then
                check_result "  README.md exists for $REPO_NAME" "pass"
            else
                check_result "  README.md exists for $REPO_NAME" "warn" "Optional but recommended"
            fi
        else
            check_result "Skill directory exists: ${REPO_NAME}-guidelines" "fail"
        fi
    done
    echo ""
fi

# Check 8: Guidelines
echo -e "${CYAN}Checking Guidelines...${NC}"
GUIDELINES_DIR="$ORCHESTRATOR_ROOT/shared/guidelines"

if [ -f "$GUIDELINES_DIR/architectural-principles.md" ]; then
    check_result "architectural-principles.md exists" "pass"

    # Check for placeholders
    if grep -q "{{.*}}" "$GUIDELINES_DIR/architectural-principles.md"; then
        check_result "  architectural-principles.md has no placeholders" "fail"
    else
        check_result "  architectural-principles.md has no placeholders" "pass"
    fi
else
    check_result "architectural-principles.md exists" "fail"
fi

if [ -f "$GUIDELINES_DIR/error-handling.md" ]; then
    check_result "error-handling.md exists" "pass"

    if grep -q "{{.*}}" "$GUIDELINES_DIR/error-handling.md"; then
        check_result "  error-handling.md has no placeholders" "fail"
    else
        check_result "  error-handling.md has no placeholders" "pass"
    fi
else
    check_result "error-handling.md exists" "fail"
fi

if [ -f "$GUIDELINES_DIR/testing-standards.md" ]; then
    check_result "testing-standards.md exists" "pass"

    if grep -q "{{.*}}" "$GUIDELINES_DIR/testing-standards.md"; then
        check_result "  testing-standards.md has no placeholders" "fail"
    else
        check_result "  testing-standards.md has no placeholders" "pass"
    fi
else
    check_result "testing-standards.md exists" "fail"
fi

if [ -f "$GUIDELINES_DIR/documentation-standards.md" ]; then
    check_result "documentation-standards.md exists" "pass"
else
    check_result "documentation-standards.md exists" "warn" "Should exist (not auto-generated)"
fi
echo ""

# Check 9: Shared directories
echo -e "${CYAN}Checking Shared Resources...${NC}"
if [ -d "$ORCHESTRATOR_ROOT/shared/agents" ]; then
    check_result "shared/agents/ directory exists" "pass"
    AGENT_COUNT=$(find "$ORCHESTRATOR_ROOT/shared/agents" -name "*.md" -type f | wc -l | tr -d ' ')
    echo -e "  ${CYAN}→${NC} Agents found: $AGENT_COUNT"
else
    check_result "shared/agents/ directory exists" "fail"
fi

if [ -d "$ORCHESTRATOR_ROOT/shared/hooks" ]; then
    check_result "shared/hooks/ directory exists" "pass"
else
    check_result "shared/hooks/ directory exists" "fail"
fi

if [ -d "$ORCHESTRATOR_ROOT/shared/commands" ]; then
    check_result "shared/commands/ directory exists" "pass"
else
    check_result "shared/commands/ directory exists" "fail"
fi
echo ""

# Check 11: Repository paths
if [ -f "$CONFIG_FILE" ] && command -v jq &> /dev/null; then
    echo -e "${CYAN}Checking Repository Paths...${NC}"

    REPO_COUNT=$(jq '.repositories | length' "$CONFIG_FILE")
    for i in $(seq 0 $((REPO_COUNT - 1))); do
        REPO_NAME=$(jq -r ".repositories[$i].name" "$CONFIG_FILE")
        REPO_PATH=$(jq -r ".repositories[$i].path" "$CONFIG_FILE")
        REPO_ABS_PATH="$ORCHESTRATOR_ROOT/$REPO_PATH"

        if [ -d "$REPO_ABS_PATH" ]; then
            check_result "Repository exists: $REPO_NAME at $REPO_PATH" "pass"
        else
            check_result "Repository exists: $REPO_NAME at $REPO_PATH" "warn" "Directory not found (setup may be incomplete)"
        fi
    done
    echo ""
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Validation Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Total Checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed:${NC}       $PASSED_CHECKS"
if [ $FAILED_CHECKS -gt 0 ]; then
    echo -e "${RED}Failed:${NC}       $FAILED_CHECKS"
fi
if [ $WARNING_CHECKS -gt 0 ]; then
    echo -e "${YELLOW}Warnings:${NC}     $WARNING_CHECKS"
fi
echo ""

# Exit status
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✓ Setup validation passed!${NC}"
    echo ""
    echo "Your orchestrator is properly configured."
    echo ""
    echo "Next steps:"
    echo "  1. Create symlinks: ./setup/scripts/create-symlinks.sh"
    echo "  2. Test in a repository"
    echo "  3. Delete setup directory: rm -rf setup/"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Setup validation failed${NC}"
    echo ""
    echo "Please fix the errors above and run validation again."
    echo ""
    echo "Common fixes:"
    echo "  - Re-run setup wizard: /setup-orchestrator"
    echo "  - Check SETUP_CONFIG.json is valid"
    echo "  - Ensure all templates were processed"
    echo ""
    exit 1
fi
