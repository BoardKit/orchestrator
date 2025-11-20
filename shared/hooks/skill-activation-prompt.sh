#!/bin/bash
set -e

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
cat | npx tsx skill-activation-prompt.ts
