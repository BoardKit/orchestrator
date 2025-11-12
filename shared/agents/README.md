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

### 1. code-architecture-reviewer

**When to use:** Need code review for architectural issues, best practices, or consistency

**What it does:**
- Reviews code for architectural patterns and best practices
- Checks consistency with your organization's architecture and repository structure
- Identifies technical debt and design issues
- Suggests improvements with rationale
- Creates detailed review document in markdown

**How to invoke:**
```
Task tool:
  subagent_type: "code-architecture-reviewer"
  prompt: "Review the diagram service module for architectural issues"
```

**Input expectations:**
- Specific files, directories, or modules to review
- Clear scope (e.g., "authentication system" vs "entire codebase")

**Output:**
- Code review document saved to `dev/active/[task]/[task]-code-review.md`
- Issues categorized by severity (critical, high, medium, low)
- Specific recommendations with code examples
- References to relevant guidelines

**References:**
- `guidelines/architectural-principles.md` - Organizational architecture
- `guidelines/error-handling.md` - Error handling patterns
- `guidelines/testing-standards.md` - Testing best practices

**Tech stack awareness:**
- Reads tech stack from `SETUP_CONFIG.json` or `CLAUDE.md`
- Adapts to your organization's specific technologies
- Common stacks: React/Vue/Angular (frontend), FastAPI/Django/Express (backend), PostgreSQL/MongoDB (database)

**Location:** `shared/agents/code-architecture-reviewer.md`

---

### 2. refactor-planner

**When to use:** Planning a refactoring project (before execution)

**What it does:**
- Analyzes code to be refactored
- Creates comprehensive refactoring plan
- Identifies affected files and dependencies
- Suggests implementation phases
- Assesses risks and creates mitigation strategies
- Estimates effort and complexity

**How to invoke:**
```
Task tool:
  subagent_type: "refactor-planner"
  prompt: "Plan refactoring of the authentication system to use JWT tokens"
```

**Input expectations:**
- What needs to be refactored and why
- Desired end state
- Any constraints (backward compatibility, deadlines)

**Output:**
- Refactoring plan saved to `dev/active/[task]/[task]-plan.md`
- Phase-by-phase breakdown
- File-by-file analysis
- Risk assessment with mitigations
- Testing strategy

**Best practices:**
- Use before starting large refactors
- Share plan with team for review
- Update plan as you discover new issues
- Pair with plan-reviewer agent to validate plan

**Location:** `shared/agents/refactor-planner.md`

---

### 3. code-refactor-master

**When to use:** Executing a refactoring (after planning)

**What it does:**
- Executes refactoring systematically
- Follows refactoring plan (if provided)
- Tracks file changes and ensures consistency
- Maintains backward compatibility when possible
- Handles imports and references
- Creates tests for refactored code

**How to invoke:**
```
Task tool:
  subagent_type: "code-refactor-master"
  prompt: "Execute the authentication refactoring per the plan in dev/active/auth-refactor/"
```

**Input expectations:**
- Reference to refactoring plan (or clear refactoring goals)
- Specific scope (which files/modules)
- Any constraints or requirements

**Output:**
- Refactored code files
- Updated tests
- Summary of changes made
- Notes on any deviations from plan

**Best practices:**
- Always plan before refactoring (use refactor-planner)
- Test after each phase
- Commit frequently
- Document breaking changes

**Workflow:**
1. Use refactor-planner to create plan
2. Review plan (optionally with plan-reviewer)
3. Use code-refactor-master to execute
4. Test and verify
5. Use code-architecture-reviewer to review result

**Location:** `shared/agents/code-refactor-master.md`

---

### 4. plan-reviewer

**When to use:** Review an implementation plan before execution

**What it does:**
- Reviews plans for completeness and feasibility
- Identifies missing considerations
- Suggests improvements and alternatives
- Validates timelines and effort estimates
- Checks for risks and edge cases
- Ensures plan aligns with architecture principles

**How to invoke:**
```
Task tool:
  subagent_type: "plan-reviewer"
  prompt: "Review the implementation plan in dev/active/png-export/"
```

**Input expectations:**
- Path to plan file or directory
- Context about the feature/change

**Output:**
- Review document with feedback
- Issues categorized (critical, suggestions, questions)
- Specific recommendations
- Approval or requests for changes

**Best practices:**
- Use for complex features
- Review before starting implementation
- Address critical issues before proceeding
- Update plan based on feedback

**References:**
- `guidelines/architectural-principles.md` - Architectural alignment
- `guidelines/cross-repo-patterns.md` - Multi-repo planning

**Location:** `shared/agents/plan-reviewer.md`

---

### 5. documentation-architect

**When to use:** Create or update documentation

**What it does:**
- Creates comprehensive documentation
- Follows documentation standards (guidelines/documentation-standards.md)
- Generates READMEs, API docs, guides
- Updates CLAUDE.md when resources change
- Creates dev docs (plan, context, tasks) for complex features
- Maintains consistent documentation structure

**How to invoke:**
```
Task tool:
  subagent_type: "documentation-architect"
  prompt: "Create documentation for the new diagram export feature"
```

**Input expectations:**
- What needs documentation (feature, module, API)
- Target audience (developers, users, AI agents)
- Format preference (README, API docs, dev docs)

**Output:**
- Documentation files (markdown, JSDoc, docstrings)
- Updated existing docs if needed
- Consistent structure and formatting

**References:**
- `guidelines/documentation-standards.md` - Standards and conventions
- `guidelines/architectural-principles.md` - Architecture to document
- Dev docs pattern (plan, context, tasks)

**Best practices:**
- Document as you code, not after
- Update docs in same PR as code
- Follow established conventions
- Include examples and rationale

**Location:** `shared/agents/documentation-architect.md`

---

### 6. auto-error-resolver

**When to use:** Fix TypeScript errors or resolve build issues

**What it does:**
- Analyzes TypeScript compilation errors
- Suggests and applies fixes
- Checks cached error logs for context
- Handles import issues, type mismatches, missing properties
- Validates fixes compile successfully
- Documents fixes applied

**How to invoke:**
```
Task tool:
  subagent_type: "auto-error-resolver"
  prompt: "Fix TypeScript errors in the frontend components"
```

**Input expectations:**
- Error messages or file paths with errors
- Context about what changed recently (if available)

**Output:**
- Fixed code files
- Summary of errors resolved
- Any remaining issues that need manual attention

**Best practices:**
- Run TypeScript compiler first to identify errors
- Provide error output to agent
- Review fixes before committing
- May need multiple iterations for complex errors

**Scope:**
- Primarily TypeScript errors
- Some JavaScript issues
- Import and type issues
- Not for logical bugs (use code-architecture-reviewer)

**Location:** `shared/agents/auto-error-resolver.md`

---

### 7. web-research-specialist

**When to use:** Need web research on technologies, patterns, or best practices

**What it does:**
- Conducts web research on specified topics
- Synthesizes findings from multiple sources
- Provides actionable recommendations
- Cites sources for verification
- Compares approaches and trade-offs
- Focuses on latest best practices

**How to invoke:**
```
Task tool:
  subagent_type: "web-research-specialist"
  prompt: "Research best practices for handling file uploads in FastAPI with Supabase Storage"
```

**Input expectations:**
- Clear research question or topic
- Context about your specific use case
- Any constraints (tech stack, requirements)

**Output:**
- Research summary document
- Key findings and recommendations
- Code examples (if applicable)
- Links to sources
- Comparison of approaches

**Best practices:**
- Be specific about what you need to know
- Provide context about your project
- Review sources yourself for critical decisions
- Cross-reference with official documentation

**Use cases:**
- Learning new technologies
- Finding best practices
- Comparing libraries or approaches
- Debugging unusual issues
- Staying current with tech trends

**Location:** `shared/agents/web-research-specialist.md`

---

### 8. cross-repo-doc-sync

**When to use:** Synchronize orchestrator documentation with changes made in your application repositories

**What it does:**
- Monitors changes across your organization's multi-repo system
- Detects changes in application repos that affect orchestrator documentation
- Updates CLAUDE.md, guidelines, and skills to reflect current implementation
- Ensures documentation stays synchronized with code changes
- Validates cross-references and code examples in docs
- Provides sync reports showing what was updated and why

**How to invoke:**
```
Task tool:
  subagent_type: "cross-repo-doc-sync"
  prompt: "Sync orchestrator documentation based on recent changes in my application repositories"
```

**Input expectations:**
- Which repos to analyze (check SETUP_CONFIG.json for repository names)
- Optionally: specific commit range or features to focus on
- Context about major changes if available

**Output:**
- Cross-repo documentation sync report
- Updated orchestrator documentation files
- Summary of changes detected and documentation updated
- Verification checklist
- Recommendations for manual review

**Best practices:**
- Run after significant changes in app/core
- Review the sync report before committing changes
- Sync regularly to prevent documentation drift
- Use when adding new features that affect multiple repos

**Use cases:**
- After refactoring backend/core architecture
- When adding new API endpoints
- After adding new features or components
- When authentication patterns change
- Before major releases to ensure docs are current

**Cross-repo access:**
- Reads repository paths from `SETUP_CONFIG.json`
- Uses git commands to detect changes
- Only writes to orchestrator documentation
- Preserves symlinked resource structure

**References:**
- `guidelines/architectural-principles.md` - Repository boundaries
- `guidelines/cross-repo-patterns.md` - Multi-repo workflows
- `guidelines/documentation-standards.md` - Documentation conventions

**Location:** `shared/agents/cross-repo-doc-sync.md`

---

## Agent Invocation Patterns

### Single Agent Invocation

**Simple case:**
```
You: "I need a code review for the authentication module"

Agent Response: Uses Task tool with:
- subagent_type: "code-architecture-reviewer"
- prompt: "Review app/backend/auth/ for architectural issues..."

Result: Code review document created
```

---

### Sequential Agent Chaining

**For complex workflows, use agents in sequence:**

**Example: Planning and executing a refactor**
```
1. User: "I want to refactor the authentication system"

2. Agent: Invokes refactor-planner
   Output: Refactoring plan created

3. Agent: (Optionally) Invokes plan-reviewer
   Output: Plan reviewed and approved

4. Agent: Invokes code-refactor-master
   Output: Code refactored

5. Agent: Invokes code-architecture-reviewer
   Output: Refactored code reviewed

6. Agent: (Optionally) Invokes documentation-architect
   Output: Documentation updated
```

---

### Parallel vs Sequential

**When to run agents in parallel:**
- Independent tasks (review different modules)
- Different aspects of same code (architecture review + doc creation)

**When to run agents sequentially:**
- Dependent tasks (plan → execute → review)
- Iterative refinement (review → fix → review again)

**Example parallel invocation:**
```
Task tool call 1: code-architecture-reviewer for backend
Task tool call 2: code-architecture-reviewer for frontend
(Both in same message, run in parallel)
```

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

## Agent Outputs and Deliverables

### Where Agents Save Files

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

### Reviewing Agent Output

**Always review agent work:**
1. **Read the output document** (plan, review, etc.)
2. **Check for accuracy** (do recommendations make sense?)
3. **Validate references** (are guideline references correct?)
4. **Test changes** (if code was modified)
5. **Ask questions** (if anything is unclear)

**Agents can make mistakes:**
- May misunderstand context
- May suggest overly complex solutions
- May miss edge cases
- May not have full context

**You are responsible** for accepting or rejecting agent recommendations.

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

## Agent Selection Decision Tree

### I need to...

**Review code for quality:**
→ **code-architecture-reviewer**

**Plan a large refactoring:**
→ **refactor-planner** → **plan-reviewer** → **code-refactor-master**

**Execute a refactoring:**
→ **code-refactor-master** (with plan)

**Review an implementation plan:**
→ **plan-reviewer**

**Create or update documentation:**
→ **documentation-architect**

**Fix TypeScript errors:**
→ **auto-error-resolver**

**Research a topic or technology:**
→ **web-research-specialist**

**Sync orchestrator docs after changes in app/core:**
→ **cross-repo-doc-sync**

**Get quick inline guidance:**
→ Wait for a skill to auto-trigger (not an agent)

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

## FAQ

**Q: Can I create my own agents?**
A: Yes! See skill-developer skill for guidance on creating agents. Follow the same pattern as existing agents.

**Q: Can agents invoke other agents?**
A: Yes, agents can chain other agents using the Task tool, just like you can.

**Q: How do I know which agent to use?**
A: Use the decision tree above, or check CLAUDE.md's "When to Use What" section.

**Q: Can agents modify code directly?**
A: Yes, some agents (code-refactor-master, auto-error-resolver) modify code. Always review changes.

**Q: Do agents have access to all files?**
A: Agents can read any file in the repository, but should only modify files relevant to their task.

**Q: Can agents use external APIs?**
A: Agents can use tools like WebFetch for research, but don't make API calls directly (use core package).

---

## See Also

- **CLAUDE.md** - Discovery hub, when to use agents vs skills
- **guidelines/architectural-principles.md** - Architecture for code review
- **guidelines/documentation-standards.md** - Documentation patterns
- **skill-developer skill** - Creating new agents/skills

---

**End of Agent Capabilities Guide**
