# Dev Docs Pattern

This command creates a structured three-document complete description for complex tasks and features. It helps maintain context across Claude Code sessions and context resets, enabling seamless work resumption. For developers, it provides a structured way to track progress, document decisions, plan architecture, and think through implementation details before coding begins.

---

## The Problem

Context resets lose:
- Implementation decisions
- Progress tracking
- Key files and rationale
- What you were working on

---

## The Solution

A **three-file structure** that survives context resets:

```
dev/active/[task-name]/
├── [task-name]-plan.md      # Strategic plan & phases
├── [task-name]-context.md   # Progress & decisions
└── [task-name]-tasks.md     # Checklist
```

---

## When to Use

✅ **Use for:**
- Tasks taking > 2 hours
- Work spanning multiple sessions
- Complex features needing planning

❌ **Skip for:**
- Simple bug fixes
- Single-file changes
- Quick edits

---

## How It Works

### 1. Create Dev Docs

Run in the repo where you'll work:
```
/dev-docs [task-name]
```

**What you provide:** Describe the feature/task in detail and discuss the approach with Claude.

**What it creates:** `dev/active/[task-name]/` directory with three files.

Note, this creates the directory in the repo you are working in, not in the orchestrator. 


### 2. During Development

- **Update context.md** after each milestone with:
  - Session progress (completed, in-progress, blockers)
  - Key decisions made
  - Files modified and why

- **Check off tasks** in tasks.md as you complete them

### 3. Before Context Reset

Run:
```
/dev-docs-update
```

Or tell Claude: "Update dev docs with latest progress"

**What it does:** Updates context.md and tasks.md with current state so you can resume seamlessly.

### 4. After Context Reset

Once you return to the project, you only need to instruct Claude to read the files, which will then allow it to resume exactly where you left off.

---

## File Breakdown

### `[task-name]-plan.md`
Comprehensive strategic plan with:
- Executive summary
- Implementation phases
- Detailed tasks with acceptance criteria
- Risk assessment
- Timeline estimates

### `[task-name]-context.md` ⭐ **Most Important**

Current state of the work:
- **SESSION PROGRESS** (YYYY-MM-DD):
  - ✅ COMPLETED
  - 🟡 IN PROGRESS
  - ⚠️ BLOCKERS
- Key files and their purpose
- Implementation decisions
- Quick resume instructions

**Update this frequently!**

### `[task-name]-tasks.md`

Checklist format:
```markdown
## Phase 1: Setup
- [ ] Task 1
- [x] Task 2 (completed)
- [ ] Task 3
```

---

## Best Practices

1. **Update SESSION PROGRESS** in context.md after each milestone
2. **Be specific** in task descriptions - include acceptance criteria
3. **Document decisions** - Why you chose X over Y
4. **Keep context.md current** - It's the most important file for resuming work
5. **Use /dev-docs-update** before hitting context limits

---

## Example Workflow

```
1. You: "/dev-docs implement-auth-system"
   → Discuss the authentication feature with Claude

2. Claude creates:
   dev/active/implement-auth-system/
   ├── implement-auth-system-plan.md
   ├── implement-auth-system-context.md
   └── implement-auth-system-tasks.md

3. During work:
   → Check off tasks in tasks.md
   → Update context.md with progress

4. Before context reset:
   You: "/dev-docs-update"
   → Claude updates files with current state

5. After reset:
   → Claude reads files and resumes work
```

---

**Last Updated**: 2025-11-12
