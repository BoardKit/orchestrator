# Orchestrator - Claude Code Context

⚠️ **SETUP REQUIRED** - Run `/setup-orchestrator` to configure this for your organization.

**Last Updated: [DATE - will be updated by setup wizard]**

---

## Repository Overview

**What is this repo?** The Orchestrator is a **central infrastructure repository** that provides shared Claude Code resources (agents, skills, hooks, commands) to all projects via symlinks.

**Purpose:** Single source of truth for:
- Generic AI agents (code review, planning, documentation, refactoring)
- Auto-triggering skills (organization-specific development patterns)
- Hooks (skill activation, file tracking)
- Slash commands (dev docs creation)
- Shared guidelines (architecture, error handling, testing)

**Key Difference from Application Repos:**
- **orchestrator** (this repo): Shared infrastructure provider
- **your repositories**: **[Will be listed here after setup - e.g., app repo, core repo, etc.]**

**Critical:** Changes here affect ALL repos via symlinks. Test in application repos before committing.

---

## Resource Discovery Map

This section lists **everything** available in the orchestrator. Use this as your reference for what exists and when to use it.

### Skills (Auto-Trigger)

Skills activate automatically when you edit files matching specific patterns or keywords.

**[REPOSITORY-SPECIFIC SKILLS WILL BE GENERATED DURING SETUP]**

After running `/setup-orchestrator`, you will have one skill per repository, like:

#### **[repo-name]**-guidelines (Example)
**When it triggers:** Editing files in your **[repo-name]** repo
- File patterns: **[e.g., \*\*/repo-name/\*\*/\*.tsx, \*\*/repo-name/\*\*/\*.py]**
- Keywords: **[e.g., React, FastAPI, etc. - detected from your tech stack]**

**What it provides:**
- **[Tech stack-specific development patterns]**
- **[Error handling guidance for your frameworks]**
- **[Testing patterns for your tools]**

**References:** guidelines/error-handling.md, guidelines/testing-standards.md

**Status:** ⏳ Will be created during setup

---

#### skill-developer
**When it triggers:** Working on skill system
- File patterns: `**/.claude/skills/**`
- Keywords: "skill", "skill-rules.json"

**What it provides:**
- Meta-skill for creating new skills
- Skill structure and patterns
- skill-rules.json configuration
- Testing skill triggers

**Status:** ✅ Active

**Location:** `shared/skills/skill-developer/`

### Agents (Invoke via Task Tool)

Agents must be invoked explicitly using the Task tool. They don't auto-trigger.

**How to invoke an agent:**
```
Task tool with:
- subagent_type: "agent-name"
- prompt: "What you want the agent to do"
```

#### code-architecture-reviewer
**When to use:** Need code review for architectural issues, best practices, consistency

**How to invoke:**
- Task tool with subagent_type: "code-architecture-reviewer"
- Prompt: "Review the authentication module for architectural issues"

**What it does:**
- Reviews code for best practices
- Checks architectural consistency with **[your organization's]** patterns
- Identifies potential technical debt
- References: guidelines/architectural-principles.md

**Tech stack:** **[Will be customized based on your detected tech stacks]**

**Location:** `shared/agents/code-architecture-reviewer.md`

#### refactor-planner
**When to use:** Planning a refactoring project

**How to invoke:**
- Task tool with subagent_type: "refactor-planner"
- Prompt: "Plan refactoring of the authentication system"

**What it does:**
- Creates comprehensive refactoring plan
- Identifies files affected
- Suggests implementation phases
- Assesses risks

**Location:** `shared/agents/refactor-planner.md`

#### code-refactor-master
**When to use:** Executing a refactoring (after planning)

**How to invoke:**
- Task tool with subagent_type: "code-refactor-master"
- Prompt: "Execute refactoring of authentication module per plan"

**What it does:**
- Executes refactoring systematically
- Tracks file changes
- Ensures no broken imports
- Maintains backward compatibility

**Location:** `shared/agents/code-refactor-master.md`

#### plan-reviewer
**When to use:** Review an implementation plan before execution

**How to invoke:**
- Task tool with subagent_type: "plan-reviewer"
- Prompt: "Review the plan in dev/active/feature-name/"

**What it does:**
- Reviews plans for completeness
- Identifies missing considerations
- Suggests improvements
- Validates timelines

**Location:** `shared/agents/plan-reviewer.md`

#### documentation-architect
**When to use:** Create or update documentation

**How to invoke:**
- Task tool with subagent_type: "documentation-architect"
- Prompt: "Create documentation for **[your feature/module]**"

**What it does:**
- Creates concise, actionable documentation
- Follows documentation standards
- References: guidelines/documentation-standards.md
- Maintains consistent structure

**Location:** `shared/agents/documentation-architect.md`

#### auto-error-resolver
**When to use:** Fix errors or resolve build issues

**How to invoke:**
- Task tool with subagent_type: "auto-error-resolver"
- Prompt: "Fix errors in the codebase"

**What it does:**
- Analyzes errors
- Suggests and applies fixes
- Checks cached error logs
- Validates fixes

**Location:** `shared/agents/auto-error-resolver.md`

#### web-research-specialist
**When to use:** Need web research on technologies, patterns, or approaches

**How to invoke:**
- Task tool with subagent_type: "web-research-specialist"
- Prompt: "Research best practices for **[your tech stack]** error handling"

**What it does:**
- Conducts web research
- Synthesizes findings
- Provides actionable recommendations
- Cites sources

**Location:** `shared/agents/web-research-specialist.md`

#### cross-repo-doc-sync
**When to use:** Synchronize orchestrator documentation with changes in **[your repositories]**

**How to invoke:**
- Task tool with subagent_type: "cross-repo-doc-sync"
- Prompt: "Sync orchestrator docs based on recent changes in **[your repos]**"

**What it does:**
- Monitors changes across **[your]** repository system
- Updates CLAUDE.md, guidelines, and skills to reflect current implementation
- Validates cross-references and code examples
- Provides sync reports and cost metrics

**Two-phase workflow:**
1. **SYNC MODE**: Agent analyzes repos and updates docs (saves estimated metrics)
2. **UPDATE MODE**: Update metrics with actual token usage from UI
   - Re-invoke with: `"Update metrics with actual: [TOKENS] tokens, [SECONDS] seconds"`

**Cross-repo access:**
- Reads from **[paths to your repos - configured during setup]**
- Only writes to orchestrator documentation

**Metrics tracking:**
- Saves metrics to `doc-sync-logs/metrics/sync-costs.jsonl`
- Generates sync reports in `doc-sync-logs/sync-reports/`
- View dashboard: `cat doc-sync-logs/metrics/sync-dashboard.md`
- Regenerate dashboard: `./doc-sync-logs/scripts/generate-metrics-dashboard.sh`
- See `doc-sync-logs/README.md` for full documentation

**Location:** `shared/agents/cross-repo-doc-sync.md`

**Note:** Cross-repo doc sync is optional. Enable during setup if managing multiple repositories.

### Guidelines (Explicit Reference)

Guidelines are **NOT meant to be discovered organically**. They are explicitly referenced from CLAUDE.md, skills, and agents when detailed patterns are needed.

**How to use:** Read them when:
- CLAUDE.md points you to one
- A skill says "For more, see guidelines/X.md"
- An agent references one in its instructions

**[GUIDELINES WILL BE GENERATED DURING SETUP]**

#### architectural-principles.md
**What it covers:**
- **[Your organization's]** repository structure
- Separation of concerns (what belongs where)
- **[Cross-repo integration patterns - if you have multiple repos]**
- When to update which repo

**Referenced by:** CLAUDE.md, skills

**Status:** ⏳ Will be generated during setup

**Location:** `shared/guidelines/architectural-principles.md`

#### error-handling.md
**What it covers:**
- **[Your tech stack-specific error patterns]**
- **[e.g., FastAPI error handling, React error boundaries, etc.]**
- Logging standards

**Referenced by:** repo-guidelines skills, agents

**Status:** ⏳ Will be generated during setup

**Location:** `shared/guidelines/error-handling.md`

#### testing-standards.md
**What it covers:**
- **[Testing patterns for your frameworks]**
- **[e.g., Jest for frontend, pytest for backend, etc.]**
- Mock patterns and fixtures

**Referenced by:** repo-guidelines skills, agents

**Status:** ⏳ Will be generated during setup

**Location:** `shared/guidelines/testing-standards.md`

#### cross-repo-patterns.md (Optional)
**What it covers:**
- When changes span multiple repos
- Dev docs strategy for cross-repo work
- Testing cross-repo changes
- Coordination and deployment patterns

**Referenced by:** CLAUDE.md (when working across repos)

**Status:** ⏳ Will be generated if you have multiple repos

**Location:** `shared/guidelines/cross-repo-patterns.md`

#### documentation-standards.md
**What it covers:**
- Code documentation **[for your languages - e.g., Python Google-style, TypeScript JSDoc]**
- README structure
- CLAUDE.md conventions
- Dev docs pattern (plan, context, tasks)
- **CRITICAL: Conciseness principle** - Be succinct and purposeful
  - Simple features: < 200 lines
  - Complex features: < 500 lines
  - System docs: < 800 lines
  - Add detail ONLY for complex/critical functionality
  - One good example > Four mediocre examples

**Referenced by:** documentation-architect agent, cross-repo-doc-sync agent, refactor-planner agent, plan-reviewer agent

**Status:** ✅ Active (generic - already exists)

**Location:** `shared/guidelines/documentation-standards.md`

#### Database Documentation (Optional)
**Split into 3 focused documents (or more depending on complexity):**

**DATABASE_SCHEMA.md**
- Complete table structures, columns, relationships
- Custom database types (enums, etc.)
- Database functions and storage buckets
- **Location:** `shared/guidelines/DATABASE_SCHEMA.md`

**DATABASE_OPERATIONS.md**
- Common query patterns and examples
- Migration considerations and performance optimization
- Error handling patterns
- **Location:** `shared/guidelines/DATABASE_OPERATIONS.md`

**DATABASE_SECURITY.md**
- Row Level Security (RLS) policies for all tables (if applicable)
- Security best practices and recommendations
- **Location:** `shared/guidelines/DATABASE_SECURITY.md`

**Referenced by:** repo-guidelines skills, backend agents, API developers

**Status:** ⏳ Will be generated if you enable database docs during setup

### Commands (Slash Commands)

#### /dev-docs
**When to use:** Starting a complex task that needs planning and tracking

**What it does:**
- Creates `dev/active/[task-name]/` directory
- Generates three files:
  - `[task-name]-plan.md` - Comprehensive strategic plan
  - `[task-name]-context.md` - Key files, decisions, progress tracking
  - `[task-name]-tasks.md` - Checklist format for tracking

**Usage:** `/dev-docs implement-feature-name`

**Location:** `shared/commands/dev-docs.md`

#### /dev-docs-update
**When to use:** Before context reset, to update dev docs with current progress

**What it does:**
- Updates context.md with session progress
- Marks completed tasks in tasks.md
- Adds newly discovered tasks
- Captures current state

**Usage:** `/dev-docs-update`

**Location:** `shared/commands/dev-docs-update.md`

### Hooks (Auto-Execute)

Hooks execute automatically on specific events. You don't need to invoke them.

#### skill-activation-prompt
**Type:** UserPromptSubmit

**What it does:**
- Runs before every user prompt
- Checks if any skills should be suggested
- Auto-suggests skills based on user intent and file context

**Status:** ✅ Active

**Location:** `shared/hooks/skill-activation-prompt.sh` + `.ts`

#### post-tool-use-tracker
**Type:** PostToolUse

**What it does:**
- Runs after Edit/MultiEdit/Write tool usage
- Tracks file changes
- Provides context for skill activation

**Status:** ✅ Active

**Location:** `shared/hooks/post-tool-use-tracker.sh`

---

## How Resources Work

### Skills: Auto-Triggering

**Trigger Mechanism:**
1. You edit a file in one of your repositories
2. Hook (post-tool-use-tracker) detects the file path
3. skill-rules.json is checked for matching patterns/keywords
4. If match found, skill activates on next user prompt
5. Skill provides inline guidance + references to guidelines

**Example Flow:**
```
Edit: **[your-repo]**/backend/app/main.py
  ↓
Hook detects: **/**[your-repo]/**/*.py
  ↓
skill-rules.json: **[your-repo]**-guidelines matches
  ↓
Next prompt: Skill activates with **[your tech stack]** patterns
  ↓
Skill says: "For error handling, see guidelines/error-handling.md"
```

**Configuration:** `shared/skills/skill-rules.json`

### Agents: Explicit Invocation

**Invocation Mechanism:**
1. You or another agent uses the Task tool
2. Specify `subagent_type: "agent-name"`
3. Provide prompt describing what you want
4. Agent executes and returns result

**Example:**
```
Task tool:
  subagent_type: "code-architecture-reviewer"
  prompt: "Review authentication module"

Result: Code review with architectural feedback
```

**Available Agents:** See "Agents" section above for all 8 agents

### Guidelines: Explicit Reference

**Reference Mechanism:**
1. CLAUDE.md lists guideline → You read it when relevant
2. Skill references guideline → You follow the link
3. Agent references guideline → Agent reads it before acting

**NOT organic discovery:** Guidelines are reference library, not browsed randomly

### Hooks: Automatic Execution

**Execution:**
- Configured in `.claude/settings.json`
- Run automatically on events (UserPromptSubmit, PostToolUse)
- No manual invocation needed

---

## File Structure

See [README.md](./README.md) for complete architecture diagram.

**Key locations:**
- **Shared resources:** `shared/{agents,skills,hooks,commands,guidelines}/`
- **Dev docs:** `dev/active/`
- **Settings:** `.claude/settings.json`

**Symlinks:**
- Your repositories symlink to `shared/skills/`, `shared/hooks/`, `shared/commands/`
- Orchestrator also symlinks to its own shared resources in `.claude/`

---

## Critical Conventions

### 1. Update Once in Orchestrator

**Rule:** Shared resources (agents, skills, hooks, commands, guidelines) are updated ONLY in the orchestrator.

**Why:** Changes propagate automatically to all repos via symlinks

**Example:**
- ✅ Edit `orchestrator/shared/agents/code-architecture-reviewer.md`
- ❌ Edit `your-repo/.claude/agents/code-architecture-reviewer.md` (it's a symlink!)

### 2. Test in Application Repos

**Rule:** After updating shared resources, test in at least one application repo

**How:**
- Edit file in your repo → Verify skill triggers
- Invoke agent → Verify it works
- Run command → Verify it executes

**Why:** Symlinks work, but skill patterns and references need validation

### 3. Repo-Specific vs Shared

**Shared (in orchestrator):**
- Generic agents (code review, planning, documentation)
- **[Your organization]**-specific skills **[(will be generated during setup)]**
- Hooks (skill activation, file tracking)
- Commands (dev-docs)
- Guidelines (architecture, error handling, testing)

**Repo-Specific (in your repos):**
**[YOUR REPOSITORIES - will be listed here after setup]**
- **[repo-1]:**
  - Repo-specific agents: **[e.g., frontend-typescript-dev, backend-python-engineer]**
  - Repo's CLAUDE.md (repo-specific context)
- **[repo-2]:**
  - Repo-specific agents: **[e.g., frontend-typescript-dev, backend-python-engineer]**
  - Repo's CLAUDE.md (repo-specific context)
- **[etc.]**

**When to update where:**
- Generic pattern used across projects → Orchestrator
- Repo-specific pattern → Orchestrator (repo-*-guidelines skills)
- Single-repo-only pattern → That repo's specific agents/CLAUDE.md

### 4. Symlink Requirements

**Platforms:**
- ✅ macOS: Native symlink support
- ✅ Linux: Native symlink support
- ⚠️ Windows: Requires Developer Mode or administrator privileges

**Verification:**
```bash
# Check symlinks exist
ls -la your-repo/.claude/
# Should show: skills -> ../../orchestrator/shared/skills

# Test symlink works
cat your-repo/.claude/skills/skill-rules.json
# Should display content
```

---

## Troubleshooting

See [README.md](./README.md) and [QUICKSTART.md](./QUICKSTART.md) for detailed troubleshooting.

**Quick fixes:**

**Symlinks broken:**
```bash
cd your-repo/.claude
ln -sf ../../orchestrator/shared/skills skills
ln -sf ../../orchestrator/shared/hooks hooks
ln -sf ../../orchestrator/shared/commands commands
```

**Hooks not working:**
```bash
chmod +x orchestrator/shared/hooks/*.sh
```

**Skills not triggering:**
```bash
cat orchestrator/shared/skills/skill-rules.json | jq .
```

**Agent not found:**
```bash
- Verify `subagent_type` matches filename (without .md)
- Check agent exists in `shared/agents/`
```

---

## When to Use What (Decision Tree)

**[AFTER SETUP, THIS SECTION WILL BE CUSTOMIZED FOR YOUR REPOSITORIES]**

### I need quick inline guidance for **[your-repo]** development
→ **Wait for skill to auto-trigger**
- Edit file in **[your-repo]**
- **[your-repo]**-guidelines skill will activate
- Provides **[your tech stack]** patterns inline

### I need detailed architectural patterns
→ **Read guidelines/architectural-principles.md**
- Repository structure explanation
- When to update where
- Cross-repo patterns (if applicable)

### I need code review
→ **Invoke code-architecture-reviewer agent**
- Task tool with subagent_type: "code-architecture-reviewer"
- Provide prompt: "Review [module] for architectural issues"

### I need to plan a refactoring
→ **Invoke refactor-planner agent**
- Task tool with subagent_type: "refactor-planner"
- Provide prompt: "Plan refactoring of [system]"

### I need to execute a refactoring
→ **Invoke code-refactor-master agent**
- Task tool with subagent_type: "code-refactor-master"
- Provide prompt: "Execute refactoring per plan"

### I need to review an implementation plan
→ **Invoke plan-reviewer agent**
- Task tool with subagent_type: "plan-reviewer"
- Provide prompt: "Review plan in dev/active/[task]"

### I need to create documentation
→ **Invoke documentation-architect agent**
- Task tool with subagent_type: "documentation-architect"
- Provide prompt: "Document [feature/module]"

### I need to fix errors
→ **Invoke auto-error-resolver agent**
- Task tool with subagent_type: "auto-error-resolver"
- Provide prompt: "Fix errors in codebase"

### I need web research
→ **Invoke web-research-specialist agent**
- Task tool with subagent_type: "web-research-specialist"
- Provide prompt: "Research [topic]"

### I need to sync orchestrator docs after changes (Optional - if enabled)
→ **Invoke cross-repo-doc-sync agent**
- Task tool with subagent_type: "cross-repo-doc-sync"
- Prompt: "Sync orchestrator docs based on recent changes"
- After completion: Update with actual tokens using UPDATE MODE
- View metrics: `cat doc-sync-logs/metrics/sync-dashboard.md`

### I need to plan a complex task
→ **Use /dev-docs command**
- `/dev-docs task-name`
- Creates plan, context, tasks files

### I'm about to hit context limit
→ **Use /dev-docs-update command**
- `/dev-docs-update`
- Captures current progress before reset

### I need error handling patterns
→ **Read guidelines/error-handling.md**
- **[Your tech stack]** patterns
- Referenced from **[your-repo]**-guidelines skills

### I need testing patterns
→ **Read guidelines/testing-standards.md**
- **[Your framework]** testing patterns
- Mock patterns
- Referenced from **[your-repo]**-guidelines skills

### I need database schema information (Optional - if enabled)
→ **Read database documentation**
- Schema/tables: `guidelines/DATABASE_SCHEMA.md`
- Queries/performance: `guidelines/DATABASE_OPERATIONS.md`
- RLS/security: `guidelines/DATABASE_SECURITY.md`

### I'm working across multiple repos (if applicable)
→ **Read guidelines/cross-repo-patterns.md**
- Cross-repo workflow
- Testing strategies
- Coordination patterns

---

## Cross-References

**For detailed architecture:** See [README.md](./README.md)

**For setup instructions:** See [QUICKSTART.md](./QUICKSTART.md)

**For dev docs pattern:** See [dev/README.md](./dev/README.md)

**For creating skills:** See skill-developer skill in `shared/skills/skill-developer/`

**For your repo-specific context:** See `your-repo/CLAUDE.md` (in each repository)

**For cross-repo-doc-sync metrics:** See `doc-sync-logs/README.md` (if enabled)

---

## Quick Reference

### Common Tasks

**[THIS TABLE WILL BE CUSTOMIZED DURING SETUP]**

| Task | Resource | How to Access |
|------|----------|---------------|
| Get **[your tech]** patterns | **[your-repo]**-guidelines skill | Edit files in **[your-repo]** |
| Code review | code-architecture-reviewer agent | Task tool invocation |
| Plan refactoring | refactor-planner agent | Task tool invocation |
| Fix errors | auto-error-resolver agent | Task tool invocation |
| Create docs | documentation-architect agent | Task tool invocation |
| Sync cross-repo docs | cross-repo-doc-sync agent | Task tool invocation (if enabled) |
| Plan complex task | /dev-docs command | `/dev-docs task-name` |
| Architecture patterns | guidelines/architectural-principles.md | Direct read |
| Error handling | guidelines/error-handling.md | Direct read |
| Testing patterns | guidelines/testing-standards.md | Direct read |
| Database schema | guidelines/DATABASE_SCHEMA.md | Direct read (if enabled) |

### File Locations Quick Map

- **This file:** `orchestrator/CLAUDE.md`
- **Skills:** `shared/skills/[skill-name]/`
- **Agents:** `shared/agents/[agent-name].md`
- **Guidelines:** `shared/guidelines/[guideline-name].md`
- **Commands:** `shared/commands/[command-name].md`
- **Hooks:** `shared/hooks/`

---

## Notes for AI Agents

**When starting work in orchestrator:**
1. Read this file (CLAUDE.md) first
2. Check Resource Discovery Map for what's available
3. Use "When to Use What" decision tree
4. Remember: Changes here affect all repos

**When creating skills:**
- See existing repo-specific skills as examples (after setup)
- Update skill-rules.json with triggers
- Include explicit references to guidelines
- Test in application repos

**When creating guidelines:**
- Remember they're reference library, not for organic discovery
- Include "Referenced by" section
- Keep focused on one topic
- Cross-reference related guidelines

**When updating agents:**
- Add "Guidelines" section with explicit references
- Test invocation pattern
- Document in agents/README.md

---

## Setup Instructions

⚠️ **THIS ORCHESTRATOR NEEDS CONFIGURATION**

To configure this orchestrator for your organization:

1. **Run the setup wizard:**
   ```
   /setup-orchestrator
   ```

2. **Answer questions about your organization and repositories**
   - Organization name
   - Number of repositories
   - For each repo: name, path, type, tech stack

3. **Wizard will generate:**
   - Repository-specific skills
   - Tech stack-specific guidelines
   - Customized CLAUDE.md (this file)
   - Updated README.md
   - Configuration file (SETUP_CONFIG.json)

4. **Create symlinks in your repos:**
   ```bash
   ./setup/scripts/create-symlinks.sh
   ```

5. **Delete setup directory:**
   ```bash
   rm -rf setup/
   ```

**See [QUICKSTART.md](./QUICKSTART.md) for complete step-by-step instructions.**

---

**End of CLAUDE.md**
