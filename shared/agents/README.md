# Orchestrator - Agent Capabilities Guide

**Last Updated: 2025-11-12**

---

## Overview

This directory contains AI agents that can be invoked to perform specific tasks in your organization's projects. Agents are specialized AI assistants that execute complex workflows like code review, planning, documentation, and refactoring.

**Key Difference from Skills:**
- **Skills** auto-trigger when you edit files (proactive guidance)
- **Agents** must be explicitly invoked via Task tool (on-demand execution)

---

## How to Invoke Agents

### Using the Task Tool

Agents are invoked using the Task tool with the `subagent_type` parameter:

```
Task tool with:
- subagent_type: "agent-name" (matches filename without .md)
- prompt: "Detailed description of what you want the agent to do"
```

**Example:**
```
Task tool:
  subagent_type: "code-architecture-reviewer"
  prompt: "Review the authentication module in app/backend/auth/ for architectural issues and best practices"
```

---

## Agent Inventory

| Agent | When to Use | Location |
|-------|-------------|----------|
| **code-architecture-reviewer** | Review code for architectural issues, best practices, consistency | `shared/agents/code-architecture-reviewer.md` |
| **refactor-planner** | Plan a refactoring project before execution | `shared/agents/refactor-planner.md` |
| **code-refactor-master** | Execute a refactoring systematically | `shared/agents/code-refactor-master.md` |
| **plan-reviewer** | Review implementation plans before execution | `shared/agents/plan-reviewer.md` |
| **documentation-architect** | Create or update documentation | `shared/agents/documentation-architect.md` |
| **auto-error-resolver** | Fix TypeScript/build errors | `shared/agents/auto-error-resolver.md` |
| **web-research-specialist** | Research technologies, patterns, best practices | `shared/agents/web-research-specialist.md` |
| **cross-repo-doc-sync** | Sync orchestrator docs with application repo changes | `shared/agents/cross-repo-doc-sync.md` |

---

### 1. code-architecture-reviewer

**What it does:** Reviews code for architectural patterns, identifies technical debt, suggests improvements, creates detailed review document

**Example invocation:**
```
Task tool:
  subagent_type: "code-architecture-reviewer"
  prompt: "Review the authentication module in app/backend/auth/ for architectural issues"
```

**Output:** Code review document in `dev/active/[task]/[task]-code-review.md`

---

### 2. refactor-planner

**What it does:** Analyzes code, creates refactoring plan with phases, identifies dependencies, assesses risks

**Example invocation:**
```
Task tool:
  subagent_type: "refactor-planner"
  prompt: "Plan refactoring of the authentication system to use JWT tokens"
```

**Output:** Refactoring plan in `dev/active/[task]/[task]-plan.md`

---

### 3. code-refactor-master

**What it does:** Executes refactoring systematically, follows plan, maintains backward compatibility, handles imports

**Example invocation:**
```
Task tool:
  subagent_type: "code-refactor-master"
  prompt: "Execute the authentication refactoring per the plan in dev/active/auth-refactor/"
```

**Output:** Refactored code files, updated tests, summary of changes

**Recommended workflow:** refactor-planner → plan-reviewer → code-refactor-master → code-architecture-reviewer

---

### 4. plan-reviewer

**What it does:** Reviews plans for completeness, identifies missing considerations, validates timelines, checks risks

**Example invocation:**
```
Task tool:
  subagent_type: "plan-reviewer"
  prompt: "Review the implementation plan in dev/active/png-export/"
```

**Output:** Review document with feedback categorized by severity

---

### 5. documentation-architect

**What it does:** Creates concise documentation following standards, generates READMEs/API docs, updates CLAUDE.md, creates dev docs

**Example invocation:**
```
Task tool:
  subagent_type: "documentation-architect"
  prompt: "Create documentation for the new diagram export feature"
```

**Output:** Documentation files (markdown, JSDoc, docstrings) with consistent structure

---

### 6. auto-error-resolver

**What it does:** Analyzes TypeScript/build errors, applies fixes, handles imports/types, validates compilation

**Example invocation:**
```
Task tool:
  subagent_type: "auto-error-resolver"
  prompt: "Fix TypeScript errors in the frontend components"
```

**Output:** Fixed code files, summary of errors resolved

**Scope:** TypeScript/JavaScript errors, imports, types (not logical bugs)

---

### 7. web-research-specialist

**What it does:** Conducts web research, synthesizes findings, provides recommendations, cites sources, compares approaches

**Example invocation:**
```
Task tool:
  subagent_type: "web-research-specialist"
  prompt: "Research best practices for handling file uploads in FastAPI with Supabase Storage"
```

**Output:** Research summary with findings, recommendations, code examples, sources

---

### 8. cross-repo-doc-sync

**What it does:** Monitors changes across repos, updates orchestrator documentation, validates cross-references, provides sync reports

**Example invocation:**
```
Task tool:
  subagent_type: "cross-repo-doc-sync"
  prompt: "Sync orchestrator documentation based on recent changes in my application repositories"
```

**Output:** Sync report, updated orchestrator docs (CLAUDE.md, guidelines, skills)

**Uses:** Reads from `SETUP_CONFIG.json`, only writes to orchestrator, preserves symlinks

---

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

---

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

---

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

---

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

---

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
ls shared/agents/code-architecture-reviewer.md

# Verify filename matches subagent_type
# Filename: code-architecture-reviewer.md
# subagent_type: "code-architecture-reviewer" ✅
```

---

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

---

## Integration with Other Resources

### Agents + Skills

**Skills provide inline guidance, agents do deep work:**
- Skill activates: "For error handling, see guidelines/error-handling.md"
- Agent: References error-handling.md when reviewing code

**Example flow:**
```
Edit file → Skill provides quick tips → Need deep review → Invoke agent
```

---

### Agents + Guidelines

**Agents reference guidelines in their work:**
- code-architecture-reviewer checks architectural-principles.md
- documentation-architect follows documentation-standards.md
- All agents reference error-handling.md when relevant

**Agents should:**
- Read relevant guidelines before starting
- Apply guideline patterns
- Reference guidelines in recommendations

---

### Agents + Dev Docs

**Agents create and use dev docs:**
- refactor-planner creates plan files
- plan-reviewer reviews plan files
- documentation-architect creates context/tasks files
- code-refactor-master references plans during execution

---

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

---

## See Also

- **CLAUDE.md** - Discovery hub, when to use agents vs skills
- **guidelines/architectural-principles.md** - Architecture for code review
- **guidelines/documentation-standards.md** - Documentation patterns
- **skill-developer skill** - Creating new agents/skills

---

**End of Agent Capabilities Guide**
