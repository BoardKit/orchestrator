# Orchestrator Architectural Principles

**Purpose:** Core architecture and design principles for the orchestrator infrastructure.

**Referenced by:** orchestrator-guidelines skill, agents, setup wizard

---

## Overview

The orchestrator is a **centralized infrastructure repository** that provides shared Claude Code resources to all repositories in your organization via symlinks.

### Key Characteristics

1. **Single Source of Truth**: All shared resources (agents, skills, hooks, commands, guidelines) live in `shared/`
2. **Propagation via Symlinks**: Changes propagate automatically to all dependent repositories
3. **Template-Based Setup**: Wizard generates repo-specific resources from templates
4. **Modular Structure**: Resources organized by type (agents/, skills/, guidelines/, etc.)

---

## Directory Structure Principles

### 1. Shared Resources (`shared/`)

**Organization:**
```
shared/
├── agents/
│   ├── global/           # Available to all repos
│   ├── orchestrator/     # Orchestrator-only agents
│   └── {repo-name}/      # Repo-specific agents
├── copilot-agents/       # GitHub Copilot custom agents
├── commands/             # Slash commands
├── guidelines/
│   ├── global/           # Universal guidelines
│   ├── orchestrator/     # Orchestrator-specific guidelines
│   └── {repo-name}/      # Repo-specific guidelines
├── hooks/                # Event-driven scripts
├── skills/
│   ├── global/           # Universal skills
│   └── {repo-name}/      # Repo-specific skills
└── settings/
    └── {repo-name}/      # Per-repo settings files
```

**Naming Convention:**
- **global/**: Resources available to ALL repositories
- **orchestrator/**: Resources used ONLY when working in orchestrator
- **{repo-name}/**: Resources specific to that repository (generated during setup)

### 2. Setup System (`setup/`)

**Deleted after setup completion.**

Contains:
- Helper agents (doc-generator, skill-generator, repo-analyzer)
- Scripts (create-symlinks.sh, detect-tech-stack.sh, validate-setup.sh)
- Templates for generating repo-specific resources
- Example configurations

**Note:** Main setup wizard logic is in `shared/commands/setup-orchestrator.md` (slash command)

**Lifecycle:** Present during setup → Deleted after symlinks created and validated

### 3. Documentation (`docs/`)

**Permanent reference documentation.**

Contains:
- orchestrator-resources.md (complete file inventory)
- reconfiguration.md, troubleshooting.md
- skill_vs_guidelines.md, supported-tech-stacks.md
- repo-specific-agents.md, repo-specific-skills.md

**Never deleted.**

---

## Resource Types & Responsibilities

### Agents (`shared/agents/`)

**Purpose:** Specialized AI personas for complex tasks

**Structure:**
- Markdown files with YAML frontmatter
- Invoked via Task tool
- Can access all guidelines and CLAUDE.md

**Categories:**
1. **Global agents**: code-architecture-reviewer, refactor-planner, documentation-architect, etc.
2. **Orchestrator agents**: cross-repo-doc-sync (only available in orchestrator)
3. **Repo-specific agents**: Optional, generated if repo needs specialized assistance

### Skills (`shared/skills/`)

**Purpose:** Auto-triggering context-aware guidance

**Structure:**
- Directory-based (skill.md + optional supporting files)
- Configured via skill-rules.json
- Trigger on file patterns or keywords

**Activation:** Automatic via UserPromptSubmit hook

### Guidelines (`shared/guidelines/`)

**Purpose:** Detailed reference documentation for patterns and best practices

**Structure:**
- Markdown files organized by scope (global/, orchestrator/, {repo-name}/)
- Explicitly referenced by skills and agents
- NOT meant for organic discovery

**Scope:**
- **global/**: Language-agnostic standards (documentation-standards.md)
- **orchestrator/**: Orchestrator development patterns (this file)
- **{repo-name}/**: Tech stack-specific patterns (error-handling.md, testing-standards.md, architectural-principles.md)

### Hooks (`shared/hooks/`)

**Purpose:** Event-driven automation

**Types:**
1. **UserPromptSubmit**: skill-activation-prompt (suggests relevant skills)
2. **PostToolUse**: post-tool-use-tracker (tracks file changes for skill activation)

**Execution:** Automatic, configured in settings.json

### Commands (`shared/commands/`)

**Purpose:** Slash commands for complex workflows

**Examples:**
- `/dev-docs` - Create development documentation
- `/dev-docs-update` - Update dev docs before context reset
- `/setup-orchestrator` - Run setup wizard (orchestrator only)

**Filtering:** setup-orchestrator excluded from non-orchestrator repos

### Settings (`shared/settings/{repo-name}/`)

**Purpose:** Per-repository Claude Code configuration

**Contains:**
- Skill activation rules
- Hook configurations
- Repository-specific overrides

---

## Symlink Architecture

### Principle: Directory-Level Symlinks with Selective Distribution

**Structure in Application Repos:**
```
app-repo/
├── .claude/
│   ├── agents/
│   │   ├── global/ → ../../../orchestrator/shared/agents/global/
│   │   └── app/ → ../../../orchestrator/shared/agents/app/
│   ├── skills/
│   │   ├── global/ → ../../../orchestrator/shared/skills/global/
│   │   └── app/ → ../../../orchestrator/shared/skills/app/
│   ├── guidelines/
│   │   ├── global/ → ../../../orchestrator/shared/guidelines/global/
│   │   └── app/ → ../../../orchestrator/shared/guidelines/app/
│   ├── hooks/ → ../../orchestrator/shared/hooks/
│   ├── commands/ → ../../orchestrator/shared/commands/
│   └── settings.json → ../../orchestrator/shared/settings/app/settings.json
└── .github/ (optional)
    └── agents/ → ../../orchestrator/shared/copilot-agents/
```

**Benefits:**
1. **Selective access**: Each repo gets global resources + its own specific resources
2. **Automatic updates**: Edit in orchestrator → Changes propagate instantly
3. **No duplication**: Single source of truth
4. **Clean structure**: Organized by scope (global vs repo-specific)

---

## Setup Wizard Workflow

### Phase 1: Configuration Collection
1. Validate orchestrator structure
2. Collect org name and repo details
3. Detect tech stacks (or manual entry)
4. Configure features (database docs, copilot agents, etc.)
5. Generate SETUP_CONFIG.json

### Phase 2: File Generation
1. Create repo-specific skills from templates
2. Generate guidelines for each repo's tech stack
3. Create settings.json for each repo
4. Update skill-rules.json with triggers
5. Create CLAUDE.md for each application repo

### Phase 3: Orchestrator Customization
1. Update orchestrator CLAUDE.md with org details
2. Update README.md with repo information
3. Remove setup placeholders and warnings

### Phase 4: Validation
1. Check all generated files exist
2. Validate JSON files (SETUP_CONFIG.json, skill-rules.json, settings.json)
3. Ensure no template placeholders remain
4. Verify directory structure

**After wizard:** User runs `create-symlinks.sh` → Tests → Deletes `setup/`

---

## Modification Principles

### 1. Backward Compatibility

**When modifying shared resources:**
- Test in orchestrator first
- Test in at least one application repo
- Verify symlinks still work
- Check hooks execute correctly

**Breaking changes require:**
- Version coordination across all repos
- Clear migration path
- Documentation updates

### 2. Template Modifications

**When updating templates (`setup/templates/`):**
- Update template file
- Test wizard generation
- Verify generated output matches expected format
- Update validation script if structure changes

### 3. Documentation Currency

**After adding/removing resources:**
- Update CLAUDE.md Resource Discovery Map
- Update docs/orchestrator-resources.md
- Run cross-repo-doc-sync if architecture changes
- Update this guideline if principles change

---

## Common Patterns

### Adding a Global Agent

1. Create `shared/agents/global/new-agent.md`
2. Add YAML frontmatter — see `shared/agents/README.md` "Agent Frontmatter Format" for required fields. **Critical:** The `description` field (including examples) must be a single line using `\n` escapes.
3. Document invocation pattern
4. Add to `shared/agents/README.md`
5. Update CLAUDE.md Resource Discovery Map
6. Test via Task tool

### Adding a Repo-Specific Skill

1. Create `shared/skills/{repo-name}/skill.md`
2. Add entry to `shared/skills/skill-rules.json`:
   ```json
   {
     "name": "repo-name-guidelines",
     "paths": ["**/repo-name/**/*.ext"],
     "keywords": ["keyword1", "keyword2"]
   }
   ```
3. Update CLAUDE.md
4. Test by editing matching files in that repo

### Adding a Guideline

1. Determine scope: global/, orchestrator/, or {repo-name}/
2. Create markdown file with clear structure
3. Add "Referenced by" section at top
4. Update skills/agents that should reference it
5. Test references work in Claude Code

---

## Testing Strategy

### Pre-Commit Checklist

- [ ] Changes tested in orchestrator
- [ ] Changes tested in at least one application repo via symlinks
- [ ] Hooks execute without errors
- [ ] Skills trigger correctly
- [ ] Agents invoke successfully
- [ ] Run `./setup/scripts/validate-setup.sh` (if setup/ exists)
- [ ] No broken symlinks
- [ ] Documentation updated

### Integration Testing

**After major changes:**
1. Create fresh test repo
2. Run setup wizard
3. Create symlinks
4. Test all resource types (agents, skills, commands, hooks)
5. Verify CLAUDE.md accuracy
6. Check for placeholder leaks

---

## Security & Best Practices

### 1. No Hardcoded Secrets

Never commit:
- API keys
- Passwords
- Organization-specific credentials
- Private repository URLs

Use placeholders and SETUP_CONFIG.json instead.

### 2. Generic Templates

Templates should work for ANY organization:
- Use `{{ORG_NAME}}` placeholders
- Use `{{REPO_NAME}}` placeholders
- Use `{{TECH_STACK}}` placeholders
- Customize during setup, not in templates

### 3. Symlink Safety

**Windows compatibility:**
- Document Developer Mode requirement
- Provide mklink examples
- Test on Windows when possible

**macOS/Linux:**
- Use relative paths (../../../)
- Verify symlinks don't break when orchestrator moves

---

## File Naming Conventions

**Agents:**
- Use kebab-case: `code-architecture-reviewer.md`
- Descriptive names: what the agent does
- Add `.agent.md` for Copilot agents

**Skills:**
- Directory names: kebab-case or repo name
- Main file: `skill.md`
- Supporting files: descriptive names

**Guidelines:**
- Use kebab-case: `architectural-principles.md`
- Descriptive of content: `error-handling.md`, `testing-standards.md`

**Templates:**
- End with `.template.md` or `.template.json`
- Match target file name before `.template`

---

## References

**Related Documentation:**
- `shared/guidelines/global/documentation-standards.md` - Writing standards
- `docs/orchestrator-resources.md` - Complete file inventory
- `docs/skill_vs_guidelines.md` - When to use skills vs guidelines
- `docs/new-shared-resources.md` - Adding new resources

**Setup Documentation:**
- `QUICKSTART.md` - Setup guide
- `README.md` - Project overview
- `CLAUDE.md` - AI resource discovery

---

**Last Updated:** 2025-01-19
**Referenced By:** orchestrator-guidelines skill, setup agents, documentation agents
