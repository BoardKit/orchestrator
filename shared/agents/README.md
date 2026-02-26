# Orchestrator - Agent Capabilities Guide

**Last Updated: 2026-02-26**

---

## Overview

This directory contains AI agents that can be invoked to perform specific tasks in your organization's projects. Agents are specialized AI assistants that execute complex workflows like code review, planning, documentation, and refactoring.

**Key Difference from Skills:**
- **Skills** auto-trigger when you edit files (proactive guidance)
- **Agents** must be explicitly invoked via Task tool (on-demand execution)

## Agent Storage and Distribution

**Central Management:**
- All agents are stored in `orchestrator/shared/agents/`
- Organized in subdirectories:
  - `global/` - Available to all repositories via symlinks
  - `orchestrator/` - Only available when working in orchestrator (NOT symlinked)
  - `<repo-name>/` - (Optional) Repository-specific agents

**Selective Distribution:**
- Application repositories get symlinks ONLY to:
  - `global/` agents directory
  - Their own `<repo-name>/` agents directory (if it exists)
- Orchestrator-only agents (`orchestrator/` directory) are NEVER symlinked
- Example: The `cross-repo-doc-sync` agent in `orchestrator/` is only accessible from the orchestrator repository

**Benefits:**
- Central updates propagate to all repos automatically
- Each repo sees only relevant agents
- Clean namespace without unrelated agents
- Orchestrator-specific tools remain isolated

## Agent Frontmatter Format

Agent `.md` files require YAML frontmatter that Claude Code parses to register the agent. **Getting this wrong means the agent won't be discoverable.**

### Required Fields

| Field | Purpose |
|-------|---------|
| `name` | Agent identifier. **Must match filename** (without `.md`) |
| `description` | When to use + examples. **Must be a single line** (see below) |

### Optional Fields

| Field | Purpose |
|-------|---------|
| `model` | Model to use: `opus`, `sonnet`, or `haiku` |
| `color` | UI color hint: `green`, `cyan`, `purple`, `yellow`, etc. |

### Critical: Single-Line Description with `\n` Escapes

The `description` field — including all examples — **must be on a single line** using literal `\n` for newlines. Multi-line YAML content will break frontmatter parsing and the agent won't register.

**Correct format:**
```yaml
---
name: my-agent
description: Short description of when to use this agent.\n\nExamples:\n- <example>\n  Context: Situation description.\n  user: "User message"\n  assistant: "Assistant response"\n  <commentary>\n  Why this agent fits.\n  </commentary>\n</example>
model: opus
color: green
---
```

**Wrong format (agent won't work):**
```yaml
---
name: my-agent
description: Short description.

<example>
Context: Situation description.
user: "User message"
</example>
model: opus
---
```

The wrong format puts multi-line content as free-floating YAML that isn't part of any key, so the parser can't read the agent definition.

### Copying from an Existing Agent

The easiest way to get the format right: copy the frontmatter from `ghost-writer.md` or `cross-repo-doc-sync.md` and replace the content.

---

## How to Invoke Agents

 - You just ask Claude Code normally: "Review my auth code" or "Help me plan a refactor". Claude Code decides if it needs to launch a specialized agent; if yes, Claude Code internally uses the Task tool to launch that agent. You see the result.

- Or, if you want to explicitly invoke an agent, you ask Claude Code to use the specific agent's name.


## Agent Inventory

### Global Agents (Available to All Repos)

These agents are located in `shared/agents/global/` and are symlinked to all application repositories.

### 1. code-architecture-reviewer

**What it does:** Reviews code for architectural patterns, identifies technical debt, suggests improvements, creates detailed review document


### 2. refactor-planner

**What it does:** Analyzes code, creates refactoring plan with phases, identifies dependencies, assesses risks

### 3. code-refactor-master

**What it does:** Executes refactoring systematically, follows plan, maintains backward compatibility, handles imports

**Recommended workflow:** refactor-planner → plan-reviewer → code-refactor-master → code-architecture-reviewer


### 4. plan-reviewer

**What it does:** Reviews plans for completeness, identifies missing considerations, validates timelines, checks risks


### 5. documentation-architect

**What it does:** Creates concise documentation following standards, generates READMEs/API docs, updates CLAUDE.md, creates dev docs


### 6. auto-error-resolver

**What it does:** Analyzes TypeScript/build errors, applies fixes, handles imports/types, validates compilation

**Scope:** TypeScript/JavaScript errors, imports, types (not logical bugs)

### 7. web-research-specialist

**What it does:** Conducts web research, synthesizes findings, provides recommendations, cites sources, compares approaches

**Output:** Research summary with findings, recommendations, code examples, sources

### 8. ux-ui-designer

**What it does:** Provides UX/UI design guidance for building software interfaces, including component specifications, design system recommendations, accessibility audits, user flow analysis, and visual design patterns

**Output:** Design specifications, UX audit reports, component specs with states/props/accessibility, design token recommendations

**Specializations:**
- Design system architecture (three-tier token system)
- WCAG 2.2 accessibility compliance
- Modern visual patterns (depth, motion, glass morphism)
- Data visualization and dashboard design
- AI interface patterns

### 9. ghost-writer

**What it does:** Creates compelling, human-sounding content for user-facing materials including landing page copy, marketing content, user documentation, help articles, social media posts, and email sequences

**Output:** Conversion-focused copy, user docs, social media content, email sequences, blog posts

**Specializations:**
- Landing pages and marketing copy that converts
- User documentation that's warm and clear
- Social media content with authentic voice
- Email sequences that build connection
- Avoiding AI-sounding patterns and clichés

**Philosophy:** Produces content with genuine texture—varied sentence rhythm, specific details over abstractions, opinions with edges, and unexpected word choices that make readers pause and engage.

### Orchestrator Agents (Orchestrator Repository Only)

These agents are located in `shared/agents/orchestrator/` and are ONLY available when working in the orchestrator repository. They are NOT symlinked to application repositories.

### 10. cross-repo-doc-sync

**Location:** `shared/agents/orchestrator/cross-repo-doc-sync.md` (orchestrator-only)

**What it does:** Monitors changes across repos, updates orchestrator documentation, validates cross-references, provides sync reports

**Output:** Sync report, updated orchestrator docs (CLAUDE.md, guidelines, skills)

**Uses:** Reads from `SETUP_CONFIG.json`, only writes to orchestrator, preserves symlinks

**Important:** This agent must be invoked from within the orchestrator repository. It has access to read all configured repositories to sync documentation.

### 11. gtm-strategist

**Location:** `shared/agents/orchestrator/gtm-strategist.md` (orchestrator-only)

**What it does:** Provides go-to-market strategy, sales planning, brand-building playbooks, daily action plans, pricing strategy, and growth tactics for turning a built product into a profitable company

**Output:** Phased GTM plans, daily action lists, sales scripts, email templates, pricing recommendations, channel strategies

**Specializations:**
- Daily high-impact action plans ranked by revenue potential
- Beachhead customer identification and sales pipeline building
- Brand and content strategy across platforms
- Pricing and positioning for early-stage products
- Launch playbooks (Product Hunt, social, communities, partnerships)

**Philosophy:** Revenue is oxygen. Every recommendation must pass one test: if the founder does this today, will they be measurably closer to a sustainable business tomorrow?

### 12. codebase-auditor

**Location:** `shared/agents/orchestrator/codebase-auditor.md` (orchestrator-only)

**What it does:** Systematically crawls the codebase and compares against orchestrator documentation to identify gaps, drift, and inconsistencies

**Output:** Audit reports with stale references, missing documentation, pattern mismatches, coverage gaps, and invalid skill patterns

**Specializations:**
- Four-phase workflow: Crawl → Parse → Compare → Report
- Full audit, targeted audit, or quick check modes
- Skill coverage matrix generation
- Actionable fix recommendations with priority levels

**Best Practice:** Run weekly to catch drift, before releases for accuracy, and after major refactors.

## Agent Invocation Patterns

### Single Agent

```
You: "I need a code review for the authentication module"
→ Agent invokes: code-architecture-reviewer
→ Result: Code review document created
```

### Sequential Chaining

**For complex workflows:**
```
refactor-planner → plan-reviewer → code-refactor-master → code-architecture-reviewer
```

**Example workflow:**
1. Plan refactor (refactor-planner)
2. Review plan (plan-reviewer)
3. Execute refactor (code-refactor-master)
4. Review result (code-architecture-reviewer)

### Parallel vs Sequential

**Parallel** - Independent tasks:
- Review different modules simultaneously
- Different aspects of same code (review + documentation)

**Sequential** - Dependent tasks:
- Plan → execute → review
- Iterative refinement (review → fix → review again)


## Best Practices for Agent Prompts

### Good Prompts

**Specific and actionable:**
```
✅ "Review the payment service in app/backend/services/payment_service.py
    for architectural consistency and error handling"

✅ "Plan refactoring of the authentication system to support OAuth providers,
    maintaining backward compatibility"

✅ "Create documentation for the file export feature, including API endpoints,
    usage examples, and error handling"
```

**Bad Prompts:**
```
❌ "Review the code" (too vague)
❌ "Fix everything" (no scope)
❌ "Make it better" (no specific goal)
```


### Providing Context

**Include relevant information:**
- What you're trying to accomplish
- Any constraints or requirements
- Related files or modules
- Previous decisions or discussions
- Links to issues or docs

**Example:**
```
✅ "Review the new authentication flow in app/backend/auth/.
    We recently switched from session-based to JWT authentication.
    Focus on security best practices and error handling.
    The token validation logic is in jwt_handler.py."
```


## Agent Outputs

**Dev docs pattern:**
```
dev/active/[task-name]/
├── [task-name]-plan.md         # From refactor-planner
├── [task-name]-context.md      # From documentation-architect
├── [task-name]-tasks.md        # From documentation-architect
└── [task-name]-code-review.md  # From code-architecture-reviewer
```

**Documentation updates:**
- READMEs updated in place
- CLAUDE.md updated in place
- New docs created in appropriate locations

**Code changes:**
- Files edited directly
- Summary provided in agent output


## Troubleshooting

### Agent Not Found

**Symptom:** Error like "agent not found" or "subagent_type not recognized"

**Causes:**
- Typo in agent name
- Wrong path (agents must be in shared/agents/)
- Missing .md file

**Fix:**
```bash
# Check agent exists
ls shared/agents/global/code-architecture-reviewer.md

# Verify filename matches subagent_type
# Filename: code-architecture-reviewer.md
# subagent_type: "code-architecture-reviewer" ✅
```


### Agent Produces Unexpected Output

**Symptom:** Agent does something different than expected

**Causes:**
- Prompt was unclear or ambiguous
- Agent misunderstood context
- Agent doesn't have necessary information

**Fix:**
- Be more specific in prompt
- Provide more context
- Break task into smaller pieces
- Try rephrasing the request

---

### Agent Takes Too Long

**Symptom:** Agent seems to be stuck or taking a very long time

**Causes:**
- Task is too large (reviewing entire codebase)
- Agent is reading many files
- Complex analysis required

**Fix:**
- Narrow the scope
- Break into smaller tasks
- Be more specific about what to review


## Integration with Other Resources

### Agents + Skills

**Skills provide inline guidance, agents do deep work:**
- Skill activates: "For error handling, see guidelines/error-handling.md"
- Agent: References error-handling.md when reviewing code

**Example flow:**
```
Edit file → Skill provides quick tips → Need deep review → Invoke agent
```


### Agents + Guidelines

**Agents reference guidelines in their work:**
- code-architecture-reviewer checks architectural-principles.md
- documentation-architect follows documentation-standards.md
- All agents reference error-handling.md when relevant

**Agents should:**
- Read relevant guidelines before starting
- Apply guideline patterns
- Reference guidelines in recommendations

### Agents + Dev Docs

**Agents create and use dev docs:**
- refactor-planner creates plan files
- plan-reviewer reviews plan files
- documentation-architect creates context/tasks files
- code-refactor-master references plans during execution


## Advanced Usage

### Agent Chaining Workflows

**Feature Development Workflow:**
```
1. documentation-architect: Create initial dev docs
2. refactor-planner: Plan implementation (if refactoring)
3. plan-reviewer: Review the plan
4. [Manual implementation]
5. code-architecture-reviewer: Review implementation
6. documentation-architect: Update docs
```

**Refactoring Workflow:**
```
1. refactor-planner: Create refactoring plan
2. plan-reviewer: Review and approve plan
3. code-refactor-master: Execute phase 1
4. [Manual testing]
5. code-refactor-master: Execute phase 2
6. code-architecture-reviewer: Final review
```

---

### Customizing Agent Behavior

**Via prompt:**
- "Focus specifically on X"
- "Ignore Y for now"
- "Prioritize Z"
- "Follow the pattern in file A"

**Via context:**
- Reference specific guidelines
- Point to examples
- Provide constraints
- Share previous decisions


## See Also

- **CLAUDE.md** - Discovery hub, when to use agents vs skills
- **guidelines/architectural-principles.md** - Architecture for code review
- **guidelines/documentation-standards.md** - Documentation patterns
- **skill-developer skill** - Creating new agents/skills


**End of Agent Capabilities Guide**
