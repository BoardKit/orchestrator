# Skills vs Guidelines: Understanding the Difference

**Critical Distinction:** Skills and Guidelines serve different purposes in the orchestrator architecture.

---

## Quick Reference

| Aspect | Skills | Guidelines |
|--------|--------|------------|
| **Trigger** | Auto-activate on file patterns/keywords | Explicitly referenced only |
| **Length** | Brief (< 500 lines main file) | Can be long and detailed |
| **Purpose** | Just-in-time reminders | Comprehensive reference |
| **Location** | `.claude/skills/` | `.claude/guidelines/` |
| **Configuration** | `skill-rules.json` with triggers | None (passive docs) |
| **Discovery** | Automatic via hooks | Via links from skills/CLAUDE.md |

---

## Skills (Auto-Trigger Context)

### What They Are

Skills are **intelligent context modules** that automatically activate when you're working in specific areas of your codebase.

**Location:**
```
.claude/skills/
├── generic/
│   ├── skill-developer/          # Works on skill system
│   └── orchestrator-guidelines/  # Works on orchestrator
└── repo-specific/
    └── frontend-guidelines/      # Works on frontend code
```

### How They Work

1. **You edit a file:** `frontend/src/components/Button.tsx`
2. **Hook detects file path** via `PostToolUse` hook
3. **Checks skill-rules.json** for matching patterns
4. **Skill activates** on next user prompt
5. **Provides context:** Brief reminders + links to guidelines

### Anatomy of a Skill

**skill-rules.json entry:**
```json
{
  "name": "frontend-guidelines",
  "filePatterns": ["**/frontend/**/*.tsx", "**/frontend/**/*.ts"],
  "keywords": ["react", "component", "tailwind"]
}
```

**Skill file (skill.md):**
```markdown
---
name: frontend-guidelines
description: React, TypeScript, Tailwind development patterns for frontend
---

# Frontend Development Guidelines

## Quick Reference
- Component patterns
- State management
- Testing approach

## For Details
- Error handling → guidelines/error-handling.md
- Testing patterns → guidelines/testing-standards.md
- Architecture → guidelines/architectural-principles.md
```

### Key Characteristics

✅ **Brief** - Main file < 500 lines
✅ **Auto-trigger** - Activates when relevant
✅ **Progressive disclosure** - Points to guidelines for depth
✅ **Action-oriented** - "Use this pattern when..."

---

## Guidelines (Reference Library)

### What They Are

Guidelines are **comprehensive reference documentation** that provide detailed patterns, examples, and best practices. They never auto-trigger - you access them via explicit links.

**Location:**
```
.claude/guidelines/
├── architectural-principles.md   # How repos are organized
├── error-handling.md             # Error patterns for all frameworks
├── testing-standards.md          # Testing setup and patterns
├── documentation-standards.md    # How to write docs
└── cross-repo-patterns.md        # Working across multiple repos
```

### How They Work

1. **Skill activates** (e.g., frontend-guidelines)
2. **Skill says:** "For error handling, see guidelines/error-handling.md"
3. **You (or Claude) read** the guideline when needed
4. **Get detailed info** (800+ lines, multiple examples)

### Anatomy of a Guideline

**error-handling.md:**
```markdown
# Error Handling Guidelines

## React Error Boundaries
[Detailed examples, 200 lines]

## Try/Catch Patterns
[Detailed examples, 150 lines]

## Backend Error Handling
[Detailed examples, 200 lines]

## Logging Standards
[Detailed examples, 100 lines]

Total: ~650 lines - too long for a skill!
```

### Key Characteristics

✅ **Comprehensive** - Can be 500-1000+ lines
✅ **Passive** - Never auto-triggers
✅ **Referenced** - Linked from skills/CLAUDE.md
✅ **Educational** - "Here's how and why..."

---

## When to Use Each

### Create a Skill When:

- ✅ Needs to auto-activate in specific contexts
- ✅ Provides brief, actionable reminders
- ✅ References detailed docs elsewhere
- ✅ Applies to specific file types or keywords

**Examples:**
- `frontend-guidelines` - Activates on .tsx files
- `skill-developer` - Activates on .claude/skills/** files
- `backend-guidelines` - Activates on .py files

### Create a Guideline When:

- ✅ Detailed patterns/examples needed
- ✅ Too long for a skill (> 500 lines)
- ✅ Referenced from multiple skills
- ✅ Applies across multiple contexts

**Examples:**
- `error-handling.md` - Used by frontend, backend, core
- `testing-standards.md` - Used by all repos
- `architectural-principles.md` - System-wide patterns

---

## Real-World Example

### Scenario: Adding Error Handling to React Component

**Step 1: You edit file**
```
Edit: frontend/src/components/Dashboard.tsx
```

**Step 2: Skill activates**
```
🎯 SKILL ACTIVATION: frontend-guidelines

Quick Reminders:
- Use error boundaries for component errors
- Use try/catch for async operations
- Log errors to error tracking service

For Details:
→ guidelines/error-handling.md (React patterns)
→ guidelines/testing-standards.md (Testing error states)
```

**Step 3: Read guideline when needed**
```
User: "How do I implement error boundary?"
Claude: [Reads guidelines/error-handling.md]
       [Provides detailed implementation with examples]
```

---

## Directory Structure

### Skills Organization

```
shared/skills/
├── skill-rules.json              # Trigger configuration
├── generic/                      # All repos get these
│   ├── skill-developer/
│   │   ├── SKILL.md             # Main < 500 lines
│   │   ├── TRIGGER_TYPES.md     # Reference detail
│   │   └── TROUBLESHOOTING.md   # Reference detail
│   └── orchestrator-guidelines/
│       └── skill.md
└── repo-specific/                # Only specific repos
    ├── frontend-guidelines/
    │   └── skill.md
    └── backend-guidelines/
        └── skill.md
```

### Guidelines Organization

```
shared/guidelines/
├── architectural-principles.md   # Generated from template
├── error-handling.md             # Generated from template
├── testing-standards.md          # Generated from template
├── documentation-standards.md    # Pre-existing
├── cross-repo-patterns.md        # Generated if multi-repo
└── SKILLS_VS_GUIDELINES.md       # This file
```

---

## Integration in CLAUDE.md

Skills and guidelines are referenced differently in repository CLAUDE.md files:

### Skills Section
```markdown
## Skills (Auto-Trigger)

### frontend-guidelines
**Triggers:** Editing .tsx, .ts files in frontend/
**Provides:** Quick React/TypeScript reminders
**References:** guidelines/error-handling.md, guidelines/testing-standards.md
```

### Guidelines Section
```markdown
## Guidelines (Explicit Reference)

**NOT for organic discovery** - only read when:
- CLAUDE.md points you to one
- A skill says "For more, see guidelines/X.md"
- An agent references one

### error-handling.md
**Covers:** React error boundaries, try/catch patterns, logging
**Referenced by:** frontend-guidelines, backend-guidelines
```

---

## Best Practices

### For Skills

1. **Keep main file < 500 lines**
   - Use progressive disclosure
   - Link to reference files for depth

2. **Be action-oriented**
   - "Use this pattern"
   - "Check this before committing"
   - "See guidelines/X for how to..."

3. **Include explicit links**
   - Don't say "see error handling docs"
   - Say "see guidelines/error-handling.md"

4. **Test triggers**
   - Verify file patterns match
   - Test keyword activation
   - Ensure not over-triggering

### For Guidelines

1. **Be comprehensive**
   - Include multiple examples
   - Cover edge cases
   - Explain the "why"

2. **Use clear structure**
   - Table of contents
   - Sections with headers
   - Code examples with comments

3. **Cross-reference**
   - Link to related guidelines
   - Reference skills that use this guideline

4. **Keep updated**
   - Review when tech stack changes
   - Update examples to current patterns
   - Use cross-repo-doc-sync agent

---

## Common Mistakes

### ❌ Making Skills Too Long

**Wrong:**
```markdown
# frontend-guidelines/skill.md (1200 lines)
[Detailed React patterns - 300 lines]
[Detailed testing examples - 400 lines]
[Detailed error handling - 500 lines]
```

**Right:**
```markdown
# frontend-guidelines/skill.md (250 lines)
Quick React patterns
→ See guidelines/testing-standards.md for testing
→ See guidelines/error-handling.md for errors
```

### ❌ Making Guidelines Auto-Trigger

**Wrong:** Adding guidelines to skill-rules.json
**Right:** Guidelines are passive - referenced only

### ❌ Duplicating Content

**Wrong:** Same error handling info in skill AND guideline
**Right:** Skill has brief summary + link to guideline

### ❌ Unclear References

**Wrong:** "See the testing docs"
**Right:** "See guidelines/testing-standards.md"

---

## FAQ

**Q: Can a skill reference multiple guidelines?**
A: Yes! Skills commonly reference 2-3 guidelines (error-handling, testing, architecture).

**Q: Can guidelines reference each other?**
A: Yes! Cross-reference related guidelines for comprehensive coverage.

**Q: Should guidelines be tech-stack specific?**
A: They can be! error-handling.md might have sections for React, FastAPI, etc.

**Q: How do I decide if something is a skill or guideline?**
A: Ask: "Should this auto-trigger?" Yes = Skill. "Do I need > 500 lines?" Yes = Guideline.

**Q: Can I have both a skill and guideline with same name?**
A: No! Avoid confusion. Use `frontend-guidelines` (skill) + `error-handling.md` (guideline).

---

## See Also

- **skill-developer/** - Meta-skill for creating skills
- **documentation-standards.md** - How to write good docs
- **CLAUDE.md** - Main orchestrator context file
- **README.md** - Orchestrator overview

---

**Last Updated:** 2025-11-18
