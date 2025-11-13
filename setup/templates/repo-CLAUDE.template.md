# {{REPO_NAME}} - Claude Code Context

**Repository Type:** {{REPO_TYPE}}
**Last Updated:** {{TIMESTAMP}}

---

## Repository Overview

**What is this repo?** {{REPO_DESCRIPTION}}

**Tech Stack:**
- Frontend: {{FRONTEND_STACK}}
- Backend: {{BACKEND_STACK}}
- Database: {{DATABASE_STACK}}
- Other: {{OTHER_STACK}}

**Orchestrator Integration:** This repository uses shared infrastructure from the orchestrator via symlinks.

---

## Available Resources

### From Orchestrator (via symlinks)

**Agents** (invoke via Task tool):
- All 13 shared agents are available in `.claude/agents/`
- See orchestrator/CLAUDE.md for full agent documentation

**Skills** (auto-activate):
- `{{REPO_NAME}}-guidelines` - Activates when editing files in this repo
- `skill-developer` - Activates when working on skills
- See `.claude/skills/skill-rules.json` for trigger patterns

**Commands** (slash commands):
- `/dev-docs` - Create development documentation
- `/dev-docs-update` - Update dev docs before context reset
- `/setup-orchestrator` - Configure orchestrator (orchestrator only)

**Hooks** (auto-execute):
- `skill-activation-prompt` - Suggests skills before each prompt
- `post-tool-use-tracker` - Tracks file changes for skill activation

### Repository-Specific Context

**File Structure:**
```
{{REPO_NAME}}/
├── .claude/
│   ├── agents/      → symlink to orchestrator/shared/agents
│   ├── skills/      → symlink to orchestrator/shared/skills
│   ├── hooks/       → symlink to orchestrator/shared/hooks
│   ├── commands/    → symlink to orchestrator/shared/commands
│   └── settings.json
{{REPO_SPECIFIC_STRUCTURE}}
```

**Development Patterns:**
- Follow patterns defined in `.claude/skills/{{REPO_NAME}}-guidelines/`
- See orchestrator guidelines for detailed patterns:
  - `orchestrator/shared/guidelines/architectural-principles.md`
  - `orchestrator/shared/guidelines/error-handling.md`
  - `orchestrator/shared/guidelines/testing-standards.md`

---

## Quick Reference

### Common Tasks

| Task | How to Access |
|------|---------------|
| Get {{TECH_NAME}} development patterns | Edit files - `{{REPO_NAME}}-guidelines` skill auto-activates |
| Code review | Invoke `code-architecture-reviewer` agent |
| Plan refactoring | Invoke `refactor-planner` agent |
| Fix errors | Invoke `auto-error-resolver` agent |
| Create documentation | Invoke `documentation-architect` agent |
| Plan complex task | Use `/dev-docs` command |

### Getting Help

**For orchestrator documentation:**
- Main context: `orchestrator/CLAUDE.md`
- Guidelines: `orchestrator/shared/guidelines/`
- Skills: `orchestrator/shared/skills/`

**For {{REPO_NAME}}-specific patterns:**
- Skill: `.claude/skills/{{REPO_NAME}}-guidelines/`
- This file: `CLAUDE.md`

---

## Notes for AI Agents

When working in this repository:
1. **{{REPO_NAME}}-guidelines skill** will auto-activate when you edit files
2. **Shared agents** are available via symlinks in `.claude/agents/`
3. **Follow patterns** from the skill and orchestrator guidelines
4. **Cross-reference** with orchestrator/CLAUDE.md for complete documentation

---

**For complete orchestrator documentation, see:** `orchestrator/CLAUDE.md`
