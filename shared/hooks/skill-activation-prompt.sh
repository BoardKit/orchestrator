#!/bin/bash
# Note: Removed set -e to prevent hook failures from blocking prompts

# Resolve the actual directory where this script lives (handling symlinks)
# This ensures we can find the TypeScript file even when the hook is symlinked
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    # Resolve symlinks
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        # Handle relative symlinks
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

SCRIPT_DIR="$(get_script_dir)"

# Change to the script directory and run the TypeScript hook
cd "$SCRIPT_DIR"

# Capture stdin to a variable so we can pass it to tsx
INPUT=$(cat)

# Run the TypeScript hook and capture both stdout and stderr
OUTPUT=$(echo "$INPUT" | NODE_NO_WARNINGS=1 npx tsx skill-activation-prompt.ts 2>&1)
EXIT_CODE=$?

# If there was an error, log it but still output what we can
if [ $EXIT_CODE -ne 0 ]; then
    echo "⚡ [Skills] Hook error (exit $EXIT_CODE)" >&2
else
    SKILL_LINE=$(echo "$OUTPUT" | grep -o '\[Skills\] Activated: [^"]*' | head -1)
    if [ -n "$SKILL_LINE" ]; then
        echo "⚡ $SKILL_LINE" >&2
    else
        echo "⚡ [Skills] No skills matched" >&2
    fi
fi

# Output to stdout (filter out any error messages for clean output)
echo "$OUTPUT" | grep -v "^Error\|^Uncaught\|ExperimentalWarning"

exit 0
