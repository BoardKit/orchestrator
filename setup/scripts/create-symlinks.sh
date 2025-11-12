#!/bin/bash

# Create Symlinks Script
# Automatically creates symlinks in all repositories defined in SETUP_CONFIG.json
#
# Usage: ./setup/scripts/create-symlinks.sh
# Run from orchestrator root directory

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and orchestrator root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$ORCHESTRATOR_ROOT/SETUP_CONFIG.json"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Orchestrator Symlink Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ Error: jq is not installed${NC}"
    echo ""
    echo "jq is required to parse SETUP_CONFIG.json"
    echo ""
    echo "Install jq:"
    echo "  macOS:   brew install jq"
    echo "  Ubuntu:  sudo apt-get install jq"
    echo "  Other:   https://stedolan.github.io/jq/download/"
    echo ""
    exit 1
fi

# Check if SETUP_CONFIG.json exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ Error: SETUP_CONFIG.json not found${NC}"
    echo ""
    echo "Expected location: $CONFIG_FILE"
    echo ""
    echo "Run the setup wizard first:"
    echo "  /setup-orchestrator"
    echo ""
    exit 1
fi

# Validate JSON
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}✗ Error: SETUP_CONFIG.json is not valid JSON${NC}"
    echo ""
    exit 1
fi

echo -e "Configuration: ${GREEN}$CONFIG_FILE${NC}"
echo ""

# Get organization name
ORG_NAME=$(jq -r '.organization.name' "$CONFIG_FILE")
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

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Creating Symlinks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Process each repository
for i in $(seq 0 $((REPO_COUNT - 1))); do
    # Get repository info
    REPO_NAME=$(jq -r ".repositories[$i].name" "$CONFIG_FILE")
    REPO_PATH=$(jq -r ".repositories[$i].path" "$CONFIG_FILE")

    # Convert relative path to absolute
    REPO_ABS_PATH="$ORCHESTRATOR_ROOT/$REPO_PATH"

    echo -e "${BLUE}[$((i + 1))/$REPO_COUNT]${NC} Repository: ${GREEN}$REPO_NAME${NC}"
    echo "  Path: $REPO_PATH"

    # Check if repository exists
    if [ ! -d "$REPO_ABS_PATH" ]; then
        echo -e "  ${YELLOW}⚠ Warning: Repository not found at $REPO_ABS_PATH${NC}"
        echo "  Skipping..."
        SKIP_COUNT=$((SKIP_COUNT + 1))
        echo ""
        continue
    fi

    # Create .claude directory if it doesn't exist
    CLAUDE_DIR="$REPO_ABS_PATH/.claude"
    if [ ! -d "$CLAUDE_DIR" ]; then
        echo "  Creating .claude directory..."
        mkdir -p "$CLAUDE_DIR"
    fi

    # Calculate relative path from repo .claude to orchestrator shared
    # This ensures symlinks work regardless of where repos are cloned
    RELATIVE_PATH=$(python3 -c "import os.path; print(os.path.relpath('$ORCHESTRATOR_ROOT/shared', '$CLAUDE_DIR'))")

    # Create symlinks
    SYMLINK_ERRORS=0

    # Skills symlink
    SKILLS_LINK="$CLAUDE_DIR/skills"
    SKILLS_TARGET="$RELATIVE_PATH/skills"

    if [ -L "$SKILLS_LINK" ]; then
        echo -e "  ${GREEN}✓${NC} skills symlink already exists"
    elif [ -e "$SKILLS_LINK" ]; then
        echo -e "  ${YELLOW}⚠${NC} skills exists but is not a symlink (skipping)"
        SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
    else
        ln -s "$SKILLS_TARGET" "$SKILLS_LINK"
        echo -e "  ${GREEN}✓${NC} Created skills symlink"
    fi

    # Hooks symlink
    HOOKS_LINK="$CLAUDE_DIR/hooks"
    HOOKS_TARGET="$RELATIVE_PATH/hooks"

    if [ -L "$HOOKS_LINK" ]; then
        echo -e "  ${GREEN}✓${NC} hooks symlink already exists"
    elif [ -e "$HOOKS_LINK" ]; then
        echo -e "  ${YELLOW}⚠${NC} hooks exists but is not a symlink (skipping)"
        SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
    else
        ln -s "$HOOKS_TARGET" "$HOOKS_LINK"
        echo -e "  ${GREEN}✓${NC} Created hooks symlink"
    fi

    # Commands symlink
    COMMANDS_LINK="$CLAUDE_DIR/commands"
    COMMANDS_TARGET="$RELATIVE_PATH/commands"

    if [ -L "$COMMANDS_LINK" ]; then
        echo -e "  ${GREEN}✓${NC} commands symlink already exists"
    elif [ -e "$COMMANDS_LINK" ]; then
        echo -e "  ${YELLOW}⚠${NC} commands exists but is not a symlink (skipping)"
        SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
    else
        ln -s "$COMMANDS_TARGET" "$COMMANDS_LINK"
        echo -e "  ${GREEN}✓${NC} Created commands symlink"
    fi

    # Verify symlinks work
    VERIFY_ERRORS=0

    if [ ! -e "$SKILLS_LINK/skill-rules.json" ]; then
        echo -e "  ${RED}✗${NC} skills symlink broken (skill-rules.json not accessible)"
        VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
    fi

    if [ ! -d "$HOOKS_LINK" ]; then
        echo -e "  ${RED}✗${NC} hooks symlink broken (directory not accessible)"
        VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
    fi

    if [ ! -d "$COMMANDS_LINK" ]; then
        echo -e "  ${RED}✗${NC} commands symlink broken (directory not accessible)"
        VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
    fi

    if [ $SYMLINK_ERRORS -eq 0 ] && [ $VERIFY_ERRORS -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "  ${GREEN}✓ Repository configured successfully${NC}"
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo -e "  ${RED}✗ Repository configuration incomplete${NC}"
    fi

    echo ""
done

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Processed: $REPO_COUNT repositories"
echo -e "${GREEN}Success:${NC}   $SUCCESS_COUNT"
if [ $FAILURE_COUNT -gt 0 ]; then
    echo -e "${RED}Failed:${NC}    $FAILURE_COUNT"
fi
if [ $SKIP_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Skipped:${NC}   $SKIP_COUNT (repository not found)"
fi
echo ""

if [ $SUCCESS_COUNT -eq $REPO_COUNT ]; then
    echo -e "${GREEN}✓ All repositories configured successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test skills by editing files in your repositories"
    echo "  2. Verify skill activation works"
    echo "  3. Delete the setup/ directory: rm -rf setup/"
    echo ""
    exit 0
elif [ $FAILURE_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠ Some repositories had issues${NC}"
    echo ""
    echo "Check the errors above and:"
    echo "  1. Verify repository paths are correct"
    echo "  2. Ensure shared/skills, shared/hooks, shared/commands exist"
    echo "  3. Re-run this script after fixing issues"
    echo ""
    exit 1
else
    echo -e "${YELLOW}⚠ All repositories were skipped${NC}"
    echo ""
    echo "Verify repository paths in SETUP_CONFIG.json"
    echo ""
    exit 1
fi
