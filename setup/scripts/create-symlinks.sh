#!/bin/bash
# create-symlinks.sh - SMART SYMLINKING (v2.0)
# Only links relevant resources to each repository (generic + repo-specific)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory and orchestrator root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$ORCHESTRATOR_ROOT/SETUP_CONFIG.json"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔗 Smart Symlinking (v2.0)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ Error: jq is not installed${NC}"
    echo "Install jq: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Check for config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ Error: SETUP_CONFIG.json not found${NC}"
    echo "Run the setup wizard first: /setup-orchestrator"
    exit 1
fi

# Validate JSON
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}✗ Error: SETUP_CONFIG.json is not valid JSON${NC}"
    exit 1
fi

echo -e "Configuration: ${GREEN}$CONFIG_FILE${NC}"
echo ""

# Get organization name
ORG_NAME=$(jq -r '.organization.name // .organization // "Unknown"' "$CONFIG_FILE")
echo "Organization: $ORG_NAME"
echo ""

# Get repository count
REPO_COUNT=$(jq '.repositories | length' "$CONFIG_FILE")
echo "Repositories to process: $REPO_COUNT"
echo ""

# Check OS for symlink support
OS_TYPE="$(uname -s)"
if [[ "$OS_TYPE" == "MINGW"* ]] || [[ "$OS_TYPE" == "MSYS"* ]] || [[ "$OS_TYPE" == "CYGWIN"* ]]; then
    echo -e "${YELLOW}⚠ Warning: Windows detected${NC}"
    echo "Symlinks require Developer Mode or administrator privileges on Windows"
    echo "Continue? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi
    echo ""
fi

# Counter for success/failure
SUCCESS_COUNT=0
FAILURE_COUNT=0
SKIP_COUNT=0

# Function to create symlink safely
create_symlink() {
    local target="$1"
    local link_name="$2"
    local description="$3"

    # Check if target exists
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "  ${YELLOW}⚠${NC} Target does not exist (optional): $target"
        return 1
    fi

    # Remove existing symlink if it exists
    if [ -L "$link_name" ]; then
        rm "$link_name"
    elif [ -e "$link_name" ]; then
        echo -e "  ${YELLOW}⚠${NC} Backing up existing: $link_name"
        mv "$link_name" "${link_name}.backup"
    fi

    # Create parent directory
    mkdir -p "$(dirname "$link_name")"

    # Calculate relative path
    local link_dir="$(dirname "$link_name")"
    local rel_target="$(python3 -c "import os.path; print(os.path.relpath('$target', '$link_dir'))")"

    # Create symlink
    ln -s "$rel_target" "$link_name"

    if [ -L "$link_name" ] && [ -e "$link_name" ]; then
        echo -e "  ${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "  ${RED}✗${NC} Failed to create symlink: $link_name"
        return 1
    fi
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Creating Symlinks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Process each repository
for i in $(seq 0 $((REPO_COUNT - 1))); do
    # Get repository info
    REPO_NAME=$(jq -r ".repositories[$i].name" "$CONFIG_FILE")
    REPO_PATH=$(jq -r ".repositories[$i].path" "$CONFIG_FILE")
    CLAUDE_PATH=$(jq -r ".repositories[$i].claudePath // \".claude\"" "$CONFIG_FILE")

    echo -e "${CYAN}[$((i + 1))/$REPO_COUNT] $REPO_NAME${NC}"
    echo "  Path: $REPO_PATH"
    echo "  Claude: $CLAUDE_PATH"

    # Check if repository exists
    if [ ! -d "$REPO_PATH" ]; then
        echo -e "  ${YELLOW}⚠ Repository not found${NC}"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        echo ""
        continue
    fi

    # Create .claude directory structure
    CLAUDE_DIR="$REPO_PATH/$CLAUDE_PATH"
    mkdir -p "$CLAUDE_DIR/"{agents,skills,tsc-cache}

    ERRORS=0

    # 1. AGENTS: Global (all repos) + Repo-specific (only this repo)
    echo -e "${YELLOW}  Agents:${NC}"

    # Global agents
    create_symlink \
        "$ORCHESTRATOR_ROOT/shared/agents/global" \
        "$CLAUDE_DIR/agents/global" \
        "Global agents" || ((ERRORS++))

    # Repo-specific agents (if exist)
    if [ -d "$ORCHESTRATOR_ROOT/shared/agents/$REPO_NAME" ]; then
        create_symlink \
            "$ORCHESTRATOR_ROOT/shared/agents/$REPO_NAME" \
            "$CLAUDE_DIR/agents/$REPO_NAME" \
            "Repo-specific agents" || ((ERRORS++))
    fi

    # 2. SKILLS: Global (all repos) + Repo-specific skill (only this repo)
    echo -e "${YELLOW}  Skills:${NC}"

    # Global skills
    create_symlink \
        "$ORCHESTRATOR_ROOT/shared/skills/global" \
        "$CLAUDE_DIR/skills/global" \
        "Global skills" || ((ERRORS++))

    # Repo-specific skill
    if [ -d "$ORCHESTRATOR_ROOT/shared/skills/${REPO_NAME}" ]; then
        create_symlink \
            "$ORCHESTRATOR_ROOT/shared/skills/${REPO_NAME}" \
            "$CLAUDE_DIR/skills/${REPO_NAME}" \
            "Repo-specific skill" || ((ERRORS++))
    fi

    # skill-rules.json (shared by all)
    create_symlink \
        "$ORCHESTRATOR_ROOT/shared/skills/skill-rules.json" \
        "$CLAUDE_DIR/skills/skill-rules.json" \
        "Skill rules" || ((ERRORS++))

    # 3. COMMANDS: Filter out setup-orchestrator for non-orchestrator repos
    echo -e "${YELLOW}  Commands:${NC}"

    # Check if this is the orchestrator repo itself
    if [ "$REPO_NAME" = "orchestrator" ]; then
        # Orchestrator gets all commands including setup-orchestrator
        create_symlink \
            "$ORCHESTRATOR_ROOT/shared/commands" \
            "$CLAUDE_DIR/commands" \
            "Commands (all)" || ((ERRORS++))
    else
        # Application repos get commands WITHOUT setup-orchestrator
        # Create filtered commands directory
        FILTERED_COMMANDS="$CLAUDE_DIR/commands"
        mkdir -p "$FILTERED_COMMANDS"

        # Symlink each command file except setup-orchestrator.md
        for cmd_file in "$ORCHESTRATOR_ROOT/shared/commands"/*.md; do
            if [ -f "$cmd_file" ]; then
                cmd_name=$(basename "$cmd_file")
                if [ "$cmd_name" != "setup-orchestrator.md" ]; then
                    create_symlink \
                        "$cmd_file" \
                        "$FILTERED_COMMANDS/$cmd_name" \
                        "Command: $cmd_name" || ((ERRORS++))
                fi
            fi
        done
        echo -e "  ${GREEN}✓${NC} Commands (excluding setup-orchestrator)"
    fi

    # 4. HOOKS: All repos get same hooks
    echo -e "${YELLOW}  Hooks:${NC}"
    create_symlink \
        "$ORCHESTRATOR_ROOT/shared/hooks" \
        "$CLAUDE_DIR/hooks" \
        "Hooks" || ((ERRORS++))

    # Make hooks executable
    chmod +x "$ORCHESTRATOR_ROOT/shared/hooks/"*.sh 2>/dev/null || true

    # 5. GUIDELINES: Global (all repos) + Repo-specific (only this repo)
    echo -e "${YELLOW}  Guidelines:${NC}"

    # Global guidelines
    create_symlink \
        "$ORCHESTRATOR_ROOT/shared/guidelines/global" \
        "$CLAUDE_DIR/guidelines/global" \
        "Global guidelines" || ((ERRORS++))

    # Repo-specific guidelines
    if [ -d "$ORCHESTRATOR_ROOT/shared/guidelines/${REPO_NAME}" ]; then
        create_symlink \
            "$ORCHESTRATOR_ROOT/shared/guidelines/${REPO_NAME}" \
            "$CLAUDE_DIR/guidelines/${REPO_NAME}" \
            "Repo-specific guidelines" || ((ERRORS++))
    fi

    # 6. SETTINGS: Symlink to repo-specific settings file
    echo -e "${YELLOW}  Settings:${NC}"
    SETTINGS_FILE="$ORCHESTRATOR_ROOT/shared/settings/${REPO_NAME}/settings.json"
    SETTINGS_DIR="$ORCHESTRATOR_ROOT/shared/settings/${REPO_NAME}"

    # Create settings directory and file from template if doesn't exist
    if [ ! -f "$SETTINGS_FILE" ]; then
        mkdir -p "$SETTINGS_DIR"
        if [ -f "$ORCHESTRATOR_ROOT/setup/templates/settings.json" ]; then
            cp "$ORCHESTRATOR_ROOT/setup/templates/settings.json" "$SETTINGS_FILE"
        else
            # Use a default template
            echo '{"version": "1.0"}' > "$SETTINGS_FILE"
        fi
        echo -e "  ${GREEN}✓${NC} Generated ${REPO_NAME}/settings.json"
    fi

    create_symlink \
        "$SETTINGS_FILE" \
        "$CLAUDE_DIR/settings.json" \
        "Settings file" || ((ERRORS++))

    # 7. GITIGNORE: Add .claude/tsc-cache
    echo -e "${YELLOW}  Gitignore:${NC}"
    if [ -f "$SCRIPT_DIR/manage-gitignore.sh" ]; then
        bash "$SCRIPT_DIR/manage-gitignore.sh" "$REPO_PATH" 2>&1 | sed 's/^/  /'
    fi

    # Summary for this repo
    if [ $ERRORS -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "  ${GREEN}✓ Repository configured successfully${NC}"
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo -e "  ${RED}✗ Repository configuration incomplete ($ERRORS errors)${NC}"
    fi

    echo ""
done

# Final summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Processed: $REPO_COUNT repositories"
echo -e "${GREEN}Success:${NC}   $SUCCESS_COUNT"
if [ $FAILURE_COUNT -gt 0 ]; then
    echo -e "${RED}Failed:${NC}    $FAILURE_COUNT"
fi
if [ $SKIP_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Skipped:${NC}   $SKIP_COUNT"
fi
echo ""

if [ $SUCCESS_COUNT -eq $REPO_COUNT ]; then
    echo -e "${GREEN}✅ All repositories configured!${NC}"
    echo ""
    echo "What was created (per repository):"
    echo "  ✓ .claude/agents/global/ → orchestrator/shared/agents/global/"
    echo "  ✓ .claude/agents/{repo}/ → orchestrator/shared/agents/{repo}/ (if exists)"
    echo "  ✓ .claude/skills/global/ → orchestrator/shared/skills/global/"
    echo "  ✓ .claude/skills/{repo}/ → orchestrator/shared/skills/{repo}/"
    echo "  ✓ .claude/skills/skill-rules.json → orchestrator/shared/skills/skill-rules.json"
    echo "  ✓ .claude/commands/ → orchestrator/shared/commands/ (orchestrator only: all commands)"
    echo "  ✓ .claude/commands/*.md → orchestrator/shared/commands/*.md (other repos: excluding setup-orchestrator)"
    echo "  ✓ .claude/hooks/ → orchestrator/shared/hooks/"
    echo "  ✓ .claude/guidelines/global/ → orchestrator/shared/guidelines/global/"
    echo "  ✓ .claude/guidelines/{repo}/ → orchestrator/shared/guidelines/{repo}/"
    echo "  ✓ .claude/settings.json → orchestrator/shared/settings/{repo}/settings.json"
    echo "  ✓ .gitignore updated with .claude/tsc-cache"
    echo ""
    echo "Next steps:"
    echo "  1. Run health check: ./setup/scripts/health-check.sh"
    echo "  2. Test in Claude Code"
    echo "  3. Delete setup/ directory after validation"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠ Some issues occurred${NC}"
    echo "Review errors above and re-run after fixing"
    echo ""
    exit 1
fi
