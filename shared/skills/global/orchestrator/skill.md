---
name: orchestrator-guidelines
description: Guidance when working on orchestrator infrastructure (agents, skills, guidelines, setup wizard)
---

You are working on the **orchestrator repository** - the shared infrastructure provider for your organization's Claude Code resources.

## When This Activates

- Editing agents, skills, hooks, commands, or guidelines
- Modifying setup wizard or templates
- Updating CLAUDE.md, README.md, or SETUP_CONFIG.json

## Critical Principles

### 1. Changes Affect All Repos
Your updates propagate via symlinks to all repositories. **Test thoroughly before committing.**

### 2. Keep Generic
Avoid hardcoding organization-specific details. Use placeholders and `SETUP_CONFIG.json` for customization.

### 3. Maintain Backward Compatibility
Breaking changes require coordinated updates across all dependent repositories.

### 4. Documentation Must Stay Current
- Update CLAUDE.md when adding/removing resources
- Use cross-repo-doc-sync agent to keep docs synchronized
- Update Resource Discovery Map after changes

## Key Guidelines

**Reference these when working on orchestrator:**
- `guidelines/documentation-standards.md` - Keep docs concise and purposeful
- `guidelines/architectural-principles.md` - Multi-repo architecture patterns

## Testing Checklist

Before committing changes:
- [ ] Test in orchestrator
- [ ] Test in at least one application repo via symlinks
- [ ] Verify hooks execute correctly
- [ ] Check skills trigger as expected
- [ ] Run validation: `./setup/scripts/validate-setup.sh`

## Common Tasks

**Adding a new agent:**
1. Create `shared/agents/new-agent.md` with frontmatter
2. Update `shared/agents/README.md`
3. Update CLAUDE.md Resource Discovery Map
4. Test invocation via Task tool

**Adding a new skill:**
1. Create skill directory in `shared/skills/`
2. Add trigger rules to `shared/skills/skill-rules.json`
3. Update CLAUDE.md Resource Discovery Map
4. Test by editing matching files

**Updating guidelines:**
1. Edit guideline file
2. Check which agents/skills reference it
3. Update cross-references if needed
4. Invoke cross-repo-doc-sync if major changes

**Remember:** You're maintaining infrastructure used by multiple teams. Quality and consistency matter.
