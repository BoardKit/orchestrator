# Dev Docs Pattern

**Purpose:** Maintain context across Claude Code sessions and context resets.

## The Problem
Context resets lose implementation decisions, progress, key files, and rationale.

## The Solution
Three-file structure that survives context resets:

```
dev/active/[task-name]/
├── [task-name]-plan.md      # Strategic plan & phases
├── [task-name]-context.md   # Progress & decisions
└── [task-name]-tasks.md     # Checklist
```

## File Structure

### 1. [task-name]-plan.md
Strategic plan with phases, tasks, acceptance criteria, and risks.

### 2. [task-name]-context.md
**Most important!** Current progress, key files, decisions, and quick resume instructions.

**CRITICAL:** Update SESSION PROGRESS frequently:
```markdown
## SESSION PROGRESS (YYYY-MM-DD)
### ✅ COMPLETED
### 🟡 IN PROGRESS
### ⚠️ BLOCKERS
```

### 3. [task-name]-tasks.md
Checklist with phases and tasks in checkbox format.

## When to Use

**Use for:** Tasks > 2 hours or spanning multiple sessions
**Skip for:** Simple bug fixes, single-file changes

## Commands

**`/dev-docs [task-name]`** - Creates plan, context, and tasks files
**`/dev-docs-update`** - Updates docs before context reset

## Workflow

1. **Start:** `/dev-docs task-name`
2. **During:** Update context.md frequently, check off tasks
3. **Reset:** Claude reads files, resumes instantly

## Best Practices

- Update SESSION PROGRESS after each milestone
- Make tasks actionable with acceptance criteria
- Keep context.md current - it's most important

## Example

See `dev/active/generic-orchestrator-setup/` for real usage.
