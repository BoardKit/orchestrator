#!/bin/bash
# manage-gitignore.sh
# Safely add .claude/tsc-cache to target repository .gitignore files

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Usage: ./manage-gitignore.sh /path/to/target/repo
if [ $# -lt 1 ]; then
    echo "Usage: $0 <repo_path>"
    echo "Example: $0 /Users/dev/myproject/frontend"
    exit 1
fi

REPO_PATH="$1"
GITIGNORE="$REPO_PATH/.gitignore"
ENTRY=".claude/tsc-cache"

echo -e "${CYAN}Managing .gitignore for:${NC} $REPO_PATH"

# Check if directory exists
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${YELLOW}⚠${NC} Repository directory does not exist: $REPO_PATH"
    exit 1
fi

# Check if it's a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo -e "${YELLOW}ℹ${NC} Not a git repository - skipping .gitignore update"
    exit 0
fi

echo -e "${GREEN}✓${NC} Git repository detected"

# Function to add entry to .gitignore
add_to_gitignore() {
    local file="$1"
    local entry="$2"

    # Create .gitignore if it doesn't exist
    if [ ! -f "$file" ]; then
        echo -e "${CYAN}Creating new .gitignore${NC}"
        cat > "$file" <<EOF
# Claude Code cache
$entry
EOF
        echo -e "${GREEN}✓${NC} Created .gitignore with Claude Code entries"
        return 0
    fi

    # Check if entry already exists
    if grep -qF "$entry" "$file"; then
        echo -e "${GREEN}✓${NC} Entry already present in .gitignore"
        return 0
    fi

    # Check if .gitignore has uncommitted changes
    cd "$REPO_PATH"
    if git diff --name-only | grep -qF ".gitignore"; then
        echo -e "${YELLOW}⚠${NC} .gitignore has uncommitted changes"
        echo -e "${YELLOW}→${NC} Creating backup: .gitignore.backup"
    fi

    # Create backup
    cp "$file" "$file.backup"
    echo -e "${CYAN}Backup created:${NC} .gitignore.backup"

    # Add entry (ensure there's a newline before the comment)
    {
        # Add newline if file doesn't end with one
        tail -c1 "$file" | read -r _ || echo ""
        echo ""
        echo "# Claude Code cache"
        echo "$entry"
    } >> "$file"

    echo -e "${GREEN}✓${NC} Added $entry to .gitignore"

    # Show what was added
    echo -e "${CYAN}Added lines:${NC}"
    echo "  # Claude Code cache"
    echo "  $entry"
}

# Add the entry
add_to_gitignore "$GITIGNORE" "$ENTRY"

# Additional optional entries for Claude Code
echo ""
echo -e "${CYAN}Recommended additional entries (optional):${NC}"
echo "  .claude/settings.local.json  (local-only settings overrides)"
echo ""
echo -e "Add manually if needed: echo '.claude/settings.local.json' >> $GITIGNORE"

exit 0
