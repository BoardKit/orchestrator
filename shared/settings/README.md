# Per-Repository Settings

This directory contains settings.json files that are customized for each repository. Each repo gets its own settings file in a subdirectory, connected via symlink.

## Structure

```
settings/
├── template-settings.json          # Base template
├── example-backend/
│   └── settings.json               # Example backend settings
├── example-frontend/
│   └── settings.json               # Example frontend settings
├── {repo-name}/
│   └── settings.json               # Generated for each repo during setup
└── README.md                       # This file
```

## How It Works

During setup:
1. `template-settings.json` is used as the base
2. Setup wizard generates `{repo-name}/settings.json` for each repository
3. Each repo's `.claude/settings.json` symlinks to its specific settings file

Example symlinking:
```bash
# In frontend repo
frontend/.claude/settings.json -> ../../orchestrator/shared/settings/frontend/settings.json
```

## Customization Levels

### Minimal (Default)
- Repo name in comments
- Identical permissions across all repos
- Same hooks for all repos

### Medium (Recommended)
- Repo type-specific permissions (frontend vs backend)
- Adjust Bash permissions based on repo needs
- Custom MCP server settings per repo

### Advanced
- File pattern-specific permissions
- Repo-specific environment variables
- Custom hook configurations

## Template Structure

The `template-settings.json` includes:

- **enableAllProjectMcpServers**: Enable MCP tools (default: true)
- **permissions.allow**: Tools that can be auto-approved
- **permissions.defaultMode**: How to handle tool requests ("acceptEdits", "ask", or "reject")
- **hooks.UserPromptSubmit**: Skill activation before each prompt
- **hooks.PostToolUse**: File tracking after edits

## Per-Repo Customization Examples

### Frontend Repository
```json
{
  "permissions": {
    "allow": [
      "Edit:*",
      "Write:*",
      "MultiEdit:*",
      "Bash:npm*",
      "Bash:pnpm*",
      "Bash:git*"
    ]
  }
}
```

### Backend Repository
```json
{
  "permissions": {
    "allow": [
      "Edit:*",
      "Write:*",
      "MultiEdit:*",
      "Bash:*"
    ]
  }
}
```

### Library Repository
```json
{
  "permissions": {
    "allow": [
      "Edit:*",
      "Write:*",
      "MultiEdit:*",
      "Bash:npm*",
      "Bash:git*"
    ],
    "defaultMode": "ask"
  }
}
```

## Generation During Setup

The setup wizard (`setup/wizard/03-generate-resources.sh`):
1. Reads `SETUP_CONFIG.json` for repository info
2. Copies `template-settings.json` as base
3. Customizes based on repo type (if configured)
4. Saves to `shared/settings/{repo-name}/settings.json`
5. Creates symlink from repo to settings file

## Manual Customization

To customize a repo's settings after setup:

1. Edit `shared/settings/{repo-name}/settings.json`
2. Changes apply immediately (symlink resolves to this file)
3. Validate JSON: `jq . shared/settings/{repo-name}/settings.json`
4. Test in Claude Code

## Local Overrides

Repositories can have local-only overrides:

```bash
# In repository
echo '{"tabSize": 2}' > .claude/settings.local.json
```

Local settings merge with symlinked settings:
```javascript
finalSettings = { ...settings.json, ...settings.local.json }
```

Add to repo's `.gitignore`:
```
.claude/settings.local.json
.claude/tsc-cache/
```

## Validation

Before symlinking, settings files should be validated:

```bash
# Check JSON syntax
jq . shared/settings/{repo-name}/settings.json

# Check required fields
jq '.permissions, .hooks' shared/settings/{repo-name}/settings.json
```

## Troubleshooting

**Settings not working:**
- Check symlink: `ls -la repo/.claude/settings.json`
- Verify target exists: `cat repo/.claude/settings.json`
- Validate JSON: `jq . shared/settings/{repo-name}/settings.json`

**Want repo-specific permissions:**
- Edit `shared/settings/{repo-name}/settings.json`
- Modify `permissions.allow` array
- Changes take effect immediately

**Need to reset:**
- Copy from template: `cp shared/settings/template-settings.json shared/settings/{repo-name}/settings.json`
- Or re-run setup wizard
