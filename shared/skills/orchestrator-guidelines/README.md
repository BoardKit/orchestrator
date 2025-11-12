# Orchestrator Guidelines Skill

**Purpose:** Provides inline guidance when working on orchestrator infrastructure.

## When It Triggers

This skill activates when you edit:
- Agents: `shared/agents/**/*.md`
- Skills: `shared/skills/**/*.md`
- Guidelines: `shared/guidelines/**/*.md`
- Hooks: `shared/hooks/**/*.sh`
- Commands: `shared/commands/**/*.md`
- Setup wizard: `setup/**/*.md`
- Core files: `CLAUDE.md`, `SETUP_CONFIG.json`

## What It Provides

- Reminders that changes affect all repositories
- Testing checklist before commits
- References to relevant guidelines
- Common task workflows

## Key Reminders

1. **Changes propagate** - Test in app repos after orchestrator changes
2. **Stay generic** - Use placeholders, not hardcoded values
3. **Keep docs current** - Update CLAUDE.md when adding resources
4. **Validate** - Run `./setup/scripts/validate-setup.sh` before committing

## See Also

- `guidelines/documentation-standards.md` - Conciseness principles
- `shared/agents/README.md` - Agent development guide
- `CLAUDE.md` - Resource discovery map
