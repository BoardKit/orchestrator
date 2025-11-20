#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get orchestrator root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Orchestrator Self-Validation${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Track results
PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    if [ -n "${2:-}" ]; then
        echo -e "  ${YELLOW}→${NC} $2"
    fi
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    if [ -n "${2:-}" ]; then
        echo -e "  ${YELLOW}→${NC} $2"
    fi
    ((WARNINGS++))
}

# Change to orchestrator root
cd "$ORCHESTRATOR_ROOT"

echo -e "${CYAN}Core Infrastructure${NC}"
echo "---"

# Check 1: Shared directory structure
if [ -d "shared" ]; then
    check_pass "shared/ directory exists"
else
    check_fail "shared/ directory missing" "Run: mkdir -p shared"
fi

# Check 2: Global agents directory
if [ -d "shared/agents/global" ]; then
    check_pass "shared/agents/global/ exists"

    # Count global agents
    agent_count=$(find shared/agents/global -name "*.md" -not -name "README.md" | wc -l | tr -d ' ')
    if [ "$agent_count" -ge 7 ]; then
        check_pass "Found $agent_count global agents (expected ≥7)"
    else
        check_fail "Found only $agent_count global agents (expected ≥7)"
    fi

    # Check specific required global agents
    for agent in "code-architecture-reviewer" "refactor-planner" "code-refactor-master" \
                 "plan-reviewer" "documentation-architect" "auto-error-resolver" \
                 "web-research-specialist"; do
        if [ -f "shared/agents/global/$agent.md" ]; then
            check_pass "Global Agent: $agent.md exists"
        else
            check_fail "Global Agent: $agent.md missing"
        fi
    done

    # Check orchestrator-specific agents
    if [ -f "shared/agents/orchestrator/cross-repo-doc-sync.md" ]; then
        check_pass "Orchestrator Agent: cross-repo-doc-sync.md exists"
    else
        check_fail "Orchestrator Agent: cross-repo-doc-sync.md missing"
    fi

    if [ -f "shared/agents/orchestrator/setup-wizard.md" ]; then
        check_pass "Orchestrator Agent: setup-wizard.md exists"
    else
        check_fail "Orchestrator Agent: setup-wizard.md missing"
    fi
else
    check_fail "shared/agents/global/ missing" "Run: mkdir -p shared/agents/global"
fi

echo ""
echo -e "${CYAN}Global Skills${NC}"
echo "---"

# Check 3: Global skills directory
if [ -d "shared/skills/global" ]; then
    check_pass "shared/skills/global/ exists"

    # Check skill-developer
    if [ -d "shared/skills/global/skill-developer" ] && [ -f "shared/skills/global/skill-developer/skill.md" ]; then
        check_pass "skill-developer exists and configured"
    else
        check_fail "skill-developer missing or incomplete"
    fi

    # Check orchestrator skill
    if [ -d "shared/skills/global/orchestrator" ] && [ -f "shared/skills/global/orchestrator/skill.md" ]; then
        check_pass "orchestrator skill exists and configured"
    else
        check_fail "orchestrator skill missing or incomplete"
    fi
else
    check_fail "shared/skills/global/ missing" "Run: mkdir -p shared/skills/global"
fi

# Check 4: skill-rules.json
if [ -f "shared/skills/skill-rules.json" ]; then
    check_pass "skill-rules.json exists"

    # Validate JSON
    if jq empty shared/skills/skill-rules.json 2>/dev/null; then
        check_pass "skill-rules.json is valid JSON"
    else
        check_fail "skill-rules.json is invalid JSON" "Run: jq . shared/skills/skill-rules.json"
    fi
else
    check_fail "skill-rules.json missing"
fi

echo ""
echo -e "${CYAN}Hooks System${NC}"
echo "---"

# Check 5: Hooks directory
if [ -d "shared/hooks" ]; then
    check_pass "shared/hooks/ exists"

    # Check hook scripts exist
    for hook in "skill-activation-prompt.sh" "skill-activation-prompt.ts" "post-tool-use-tracker.sh"; do
        if [ -f "shared/hooks/$hook" ]; then
            check_pass "Hook: $hook exists"

            # Check if executable (for .sh files)
            if [[ "$hook" == *.sh ]]; then
                if [ -x "shared/hooks/$hook" ]; then
                    check_pass "Hook: $hook is executable"
                else
                    check_fail "Hook: $hook not executable" "Run: chmod +x shared/hooks/$hook"
                fi
            fi
        else
            check_fail "Hook: $hook missing"
        fi
    done

    # Check hook dependencies
    if [ -d "shared/hooks/node_modules" ]; then
        check_pass "Hook dependencies installed (node_modules/ exists)"
    else
        check_warn "Hook dependencies not installed" "Run: cd shared/hooks && npm install"
    fi

    # Check package.json exists
    if [ -f "shared/hooks/package.json" ]; then
        check_pass "hooks/package.json exists"
    else
        check_fail "hooks/package.json missing"
    fi

    # Check tsconfig.json exists
    if [ -f "shared/hooks/tsconfig.json" ]; then
        check_pass "hooks/tsconfig.json exists"
    else
        check_fail "hooks/tsconfig.json missing"
    fi
else
    check_fail "shared/hooks/ missing"
fi

echo ""
echo -e "${CYAN}Guidelines${NC}"
echo "---"

# Check 6: Guidelines directory
if [ -d "shared/guidelines/global" ]; then
    check_pass "shared/guidelines/global/ exists"

    # Check documentation-standards.md (should exist in global/)
    if [ -f "shared/guidelines/global/documentation-standards.md" ]; then
        check_pass "Global: documentation-standards.md exists"
    else
        check_fail "Global: documentation-standards.md missing" "This should exist before setup"
    fi
else
    check_fail "shared/guidelines/global/ missing" "Run: mkdir -p shared/guidelines/global"
fi

# Note: Repo-specific guidelines (architectural-principles, error-handling, testing-standards)
# will be generated in shared/guidelines/{repo-name}/ during setup

echo ""
echo -e "${CYAN}Setup Templates${NC}"
echo "---"

# Check 7: Setup templates directory
if [ -d "setup/templates" ]; then
    check_pass "setup/templates/ exists"

    # Check for guideline templates
    if [ -d "setup/templates/guidelines" ]; then
        check_pass "setup/templates/guidelines/ exists"

        # Count guideline templates (should have at least 6)
        template_count=$(find setup/templates/guidelines -name "*.md" | wc -l | tr -d ' ')
        if [ "$template_count" -ge 6 ]; then
            check_pass "Found $template_count guideline templates (expected ≥6)"
        else
            check_warn "Found only $template_count guideline templates (expected ≥6)"
        fi
    else
        check_warn "setup/templates/guidelines/ missing" "Guideline templates may not be available"
    fi

    # Check for repo-config template
    if [ -f "setup/templates/repo-config.json.template" ]; then
        check_pass "repo-config.json.template exists"
    else
        check_warn "repo-config.json.template missing" "Will need manual config"
    fi
else
    check_warn "setup/templates/ missing" "Setup wizard may have limited functionality"
fi

echo ""
echo -e "${CYAN}Commands & Settings${NC}"
echo "---"

# Check 8: Commands directory
if [ -d "shared/commands" ]; then
    check_pass "shared/commands/ exists"

    for cmd in "dev-docs.md" "dev-docs-update.md"; do
        if [ -f "shared/commands/$cmd" ]; then
            check_pass "Command: $cmd exists"
        else
            check_fail "Command: $cmd missing"
        fi
    done
else
    check_fail "shared/commands/ missing"
fi

# Check 9: Settings directory and template
if [ -d "shared/settings" ]; then
    check_pass "shared/settings/ exists"

    if [ -f "shared/settings/template-settings.json" ]; then
        check_pass "template-settings.json exists"

        # Validate template JSON
        if jq empty shared/settings/template-settings.json 2>/dev/null; then
            check_pass "template-settings.json is valid JSON"
        else
            check_fail "template-settings.json is invalid JSON"
        fi
    else
        check_fail "template-settings.json missing"
    fi
else
    check_fail "shared/settings/ missing" "Run: mkdir -p shared/settings"
fi

echo ""
echo -e "${CYAN}Orchestrator Configuration (Optional at this stage)${NC}"
echo "---"

# Check 10: Orchestrator's own .claude/ directory (optional before setup)
if [ -d ".claude" ]; then
    check_pass ".claude/ directory exists"

    if [ -f ".claude/settings.json" ] || [ -L ".claude/settings.json" ]; then
        check_pass ".claude/settings.json exists"

        # Check if it's a symlink and resolves
        if [ -L ".claude/settings.json" ]; then
            if [ -e ".claude/settings.json" ]; then
                check_pass ".claude/settings.json symlink resolves"
            else
                check_fail ".claude/settings.json is a broken symlink"
            fi
        fi
    else
        check_warn ".claude/settings.json not configured" "Will be created in Phase 5"
    fi
else
    check_warn ".claude/ directory not yet configured" "Will be created in Phase 5"
fi

echo ""
echo -e "${CYAN}Environment${NC}"
echo "---"

# Check 11: Required tools
for tool in "jq" "git" "node" "npm"; do
    if command -v "$tool" &> /dev/null; then
        version=$($tool --version 2>/dev/null | head -1 || echo "unknown")
        check_pass "$tool installed ($version)"
    else
        check_fail "$tool not installed" "Install $tool and try again"
    fi
done

# Check Node.js version (require >= 18)
if command -v node &> /dev/null; then
    node_version=$(node --version | grep -oE '[0-9]+' | head -1)
    if [ "$node_version" -ge 18 ]; then
        check_pass "Node.js version >= 18 (v$node_version)"
    else
        check_fail "Node.js version too old (v$node_version)" "Require Node.js >= 18"
    fi
fi

# Check 12: Claude Code CLI (optional but recommended)
if command -v claude &> /dev/null; then
    claude_version=$(claude --version 2>/dev/null || echo "unknown")
    check_pass "Claude Code CLI installed ($claude_version)"
else
    check_warn "Claude Code CLI not found" "Install from https://code.claude.com"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Validation Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓ Passed:${NC}   $PASSED"
echo -e "  ${YELLOW}⚠ Warnings:${NC} $WARNINGS"
echo -e "  ${RED}✗ Failed:${NC}   $FAILED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Orchestrator has $FAILED critical issue(s).${NC}"
    echo -e "${YELLOW}Please fix the issues above before running setup.${NC}"
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠ VALIDATION PASSED WITH WARNINGS${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Core infrastructure is ready.${NC}"
    echo -e "${YELLOW}$WARNINGS warning(s) found - these will be resolved during setup.${NC}"
    echo ""
    exit 0
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Orchestrator is healthy and ready for setup!${NC}"
    echo ""
    exit 0
fi
