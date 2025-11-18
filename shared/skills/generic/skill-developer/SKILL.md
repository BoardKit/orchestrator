---
name: skill-developer
description: Create and manage Claude Code skills following Anthropic best practices. Use when creating new skills, modifying skill-rules.json, understanding trigger patterns, working with hooks, debugging skill activation, or implementing progressive disclosure. Covers skill structure, YAML frontmatter, trigger types (keywords, intent patterns, file paths), enforcement levels (suggest, warn), hook mechanisms (UserPromptSubmit, PostToolUse), and the 500-line rule.
---

# Skill Developer Guide

## Purpose

Comprehensive guide for creating and managing skills in Claude Code with auto-activation system, following Anthropic's official best practices including the 500-line rule and progressive disclosure pattern.

## When to Use This Skill

Automatically activates when you mention:
- Creating or adding skills
- Modifying skill triggers or rules
- Understanding how skill activation works
- Debugging skill activation issues
- Working with skill-rules.json
- Hook system mechanics
- Claude Code best practices
- Progressive disclosure
- YAML frontmatter
- 500-line rule

---

## System Overview

### Two-Hook Architecture

**1. UserPromptSubmit Hook** (Proactive Skill Suggestions)
- **File**: `.claude/hooks/skill-activation-prompt.ts`
- **Trigger**: BEFORE Claude sees user's prompt
- **Purpose**: Suggest relevant skills based on keywords + intent patterns
- **Method**: Injects formatted reminder as context (stdout → Claude's input)
- **Use Cases**: Topic-based skills, implicit work detection

**2. PostToolUse Hook** (File Change Tracking)
- **File**: `.claude/hooks/post-tool-use-tracker.sh`
- **Trigger**: AFTER Edit/Write/MultiEdit tools complete successfully
- **Purpose**: Track which files and repos were modified during the session
- **Method**: Logs to tsc-cache, stores build/tsc commands for affected repos
- **Use Cases**: Session-scoped change tracking, build command automation

**Current Implementation:** This orchestrator uses suggestion-based skills (via UserPromptSubmit) and post-edit tracking (via PostToolUse). There is no PreToolUse blocking mechanism currently implemented.



### Configuration File

**Location**: `.claude/skills/skill-rules.json`

Defines:
- All skills and their trigger conditions
- Enforcement levels (block, suggest, warn)
- File path patterns (glob)
- Content detection patterns (regex)
- Skip conditions (session tracking, file markers, env vars)

---

## Skill Types

### 1. Critical Skills

**Purpose:** Strongly suggest critical best practices

**Characteristics:**
- Type: `"guardrail"` (naming convention, not enforced)
- Enforcement: `"suggest"` (no blocking in current implementation)
- Priority: `"critical"` or `"high"`
- Strongly suggested via UserPromptSubmit hook
- Prevent common mistakes through awareness
- Important patterns that should always be considered

**Examples:**
- `database-verification` - Suggest verification of table/column names
- `frontend-dev-guidelines` - Suggest React/TypeScript patterns

**When to Use:**
- Mistakes that could cause runtime errors
- Data integrity concerns
- Critical compatibility issues

**Note:** True blocking enforcement requires PreToolUse hooks, which are not currently implemented in this orchestrator.

### 2. Domain Skills

**Purpose:** Provide comprehensive guidance for specific areas

**Characteristics:**
- Type: `"domain"`
- Enforcement: `"suggest"`
- Priority: `"high"` or `"medium"`
- Advisory, not mandatory
- Topic or domain-specific
- Comprehensive documentation

**Examples:**
- `backend-dev-guidelines` - Node.js/Express/TypeScript patterns
- `frontend-dev-guidelines` - React/TypeScript best practices
- `error-tracking` - Sentry integration guidance

**When to Use:**
- Complex systems requiring deep knowledge
- Best practices documentation
- Architectural patterns
- How-to guides

---

## Quick Start: Creating a New Skill

### Step 1: Create Skill File

**Location:** `.claude/skills/{skill-name}/SKILL.md`

**Template:**
```markdown
---
name: my-new-skill
description: Brief description including keywords that trigger this skill. Mention topics, file types, and use cases. Be explicit about trigger terms.
---

# My New Skill

## Purpose
What this skill helps with

## When to Use
Specific scenarios and conditions

## Key Information
The actual guidance, documentation, patterns, examples
```

**Best Practices:**
- ✅ **Name**: Lowercase, hyphens, gerund form (verb + -ing) preferred
- ✅ **Description**: Include ALL trigger keywords/phrases (max 1024 chars)
- ✅ **Content**: Under 500 lines - use reference files for details
- ✅ **Examples**: Real code examples
- ✅ **Structure**: Clear headings, lists, code blocks

### Step 2: Add to skill-rules.json

See [SKILL_RULES_REFERENCE.md](SKILL_RULES_REFERENCE.md) for complete schema.

**Basic Template:**
```json
{
  "my-new-skill": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "medium",
    "promptTriggers": {
      "keywords": ["keyword1", "keyword2"],
      "intentPatterns": ["(create|add).*?something"]
    }
  }
}
```

### Step 3: Test Triggers

**Test UserPromptSubmit (Skill Activation):**
```bash
echo '{"session_id":"test","prompt":"your test prompt"}' | \
  npx tsx .claude/hooks/skill-activation-prompt.ts
```

**Test PostToolUse (File Tracking):**
```bash
cat <<'EOF' | .claude/hooks/post-tool-use-tracker.sh
{"session_id":"test","tool_name":"Edit","tool_input":{"file_path":"test.ts"}}
EOF
```

### Step 4: Refine Patterns

Based on testing:
- Add missing keywords
- Refine intent patterns to reduce false positives
- Adjust file path patterns
- Test content patterns against actual files

### Step 5: Follow Anthropic Best Practices

- ✅ Keep SKILL.md under 500 lines
- ✅ Use progressive disclosure with reference files
- ✅ Add table of contents to reference files > 100 lines
- ✅ Write detailed description with trigger keywords
- ✅ Test with 3+ real scenarios before documenting
- ✅ Iterate based on actual usage

---

## Enforcement Levels

**Current Implementation Note:** This orchestrator only implements suggestion-based enforcement via UserPromptSubmit. Blocking enforcement would require PreToolUse hooks.

### SUGGEST (Recommended)

- Reminder injected before Claude sees prompt
- Claude is aware of relevant skills
- Not enforced, just advisory
- **Use For**: All skills - domain guidance, best practices, critical patterns

**Priority Levels Within SUGGEST:**
- **critical**: "⚠️ CRITICAL SKILLS (REQUIRED)" - top of suggestion list
- **high**: "📚 RECOMMENDED SKILLS" - strongly suggested
- **medium**: "💡 SUGGESTED SKILLS" - helpful guidance
- **low**: "📌 OPTIONAL SKILLS" - nice to have

### WARN (Optional)

- Low priority suggestions
- Advisory only, minimal enforcement
- **Use For**: Nice-to-have suggestions, informational reminders

**Rarely used** - most skills use "suggest" with appropriate priority levels.

### BLOCK (Not Currently Implemented)

- Would require PreToolUse hooks
- Not available in this orchestrator's current implementation
- For future enhancement if blocking enforcement is needed

---

## Skill Priority System

**How Skills Are Surfaced:**

Skills are suggested via UserPromptSubmit hook based on:
1. **Keyword matches** in user prompt
2. **Intent pattern matches** using regex
3. **File patterns** from recent edits (tracked by PostToolUse)

**Priority Display:**

```
⚠️ CRITICAL SKILLS (REQUIRED):     priority: "critical"
📚 RECOMMENDED SKILLS:              priority: "high"
💡 SUGGESTED SKILLS:                priority: "medium"
📌 OPTIONAL SKILLS:                 priority: "low"
```

**User Control:**

Since skills are suggestions (not enforced), users can:
- Choose to invoke suggested skills or not
- Rely on Claude's judgment about which skills to use
- Request specific skills manually via Skill tool

---

## Testing Checklist

When creating a new skill, verify:

- [ ] Skill file created in `.claude/skills/{name}/SKILL.md`
- [ ] Proper frontmatter with name and description
- [ ] Entry added to `skill-rules.json`
- [ ] Keywords tested with real prompts
- [ ] Intent patterns tested with variations
- [ ] File path patterns tested with actual files
- [ ] Content patterns tested against file contents
- [ ] Block message is clear and actionable (if guardrail)
- [ ] Skip conditions configured appropriately
- [ ] Priority level matches importance
- [ ] No false positives in testing
- [ ] No false negatives in testing
- [ ] Performance is acceptable (<100ms or <200ms)
- [ ] JSON syntax validated: `jq . skill-rules.json`
- [ ] **SKILL.md under 500 lines** ⭐
- [ ] Reference files created if needed
- [ ] Table of contents added to files > 100 lines

---

## Reference Files

For detailed information on specific topics, see:

### [TRIGGER_TYPES.md](TRIGGER_TYPES.md)
Complete guide to all trigger types:
- Keyword triggers (explicit topic matching)
- Intent patterns (implicit action detection)
- File path triggers (glob patterns)
- Content patterns (regex in files)
- Best practices and examples for each
- Common pitfalls and testing strategies

### [SKILL_RULES_REFERENCE.md](SKILL_RULES_REFERENCE.md)
Complete skill-rules.json schema:
- Full TypeScript interface definitions
- Field-by-field explanations
- Complete guardrail skill example
- Complete domain skill example
- Validation guide and common errors

### [HOOK_MECHANISMS.md](HOOK_MECHANISMS.md)
Deep dive into hook internals:
- UserPromptSubmit flow (detailed)
- PostToolUse flow (detailed)
- Hook input/output contracts
- TSC-cache session tracking
- Performance considerations

**Note:** This file may reference PreToolUse hooks which are not currently implemented.

### [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
Comprehensive debugging guide:
- Skill not triggering (UserPromptSubmit)
- PostToolUse not tracking files
- False positives (too many triggers)
- Hook not executing at all
- Performance issues

**Note:** This file may reference PreToolUse debugging which is not applicable to current implementation.

### [PATTERNS_LIBRARY.md](PATTERNS_LIBRARY.md)
Ready-to-use pattern collection:
- Intent pattern library (regex)
- File path pattern library (glob)
- Content pattern library (regex)
- Organized by use case
- Copy-paste ready

### [ADVANCED.md](ADVANCED.md)
Future enhancements and ideas:
- Dynamic rule updates
- Skill dependencies
- Conditional enforcement
- Skill analytics
- Skill versioning

---

## Quick Reference Summary

### Create New Skill (5 Steps)

1. Create `.claude/skills/{name}/SKILL.md` with frontmatter
2. Add entry to `.claude/skills/skill-rules.json`
3. Test with `npx tsx` commands
4. Refine patterns based on testing
5. Keep SKILL.md under 500 lines

### Trigger Types

- **Keywords**: Explicit topic mentions
- **Intent**: Implicit action detection
- **File Paths**: Location-based activation
- **Content**: Technology-specific detection

See [TRIGGER_TYPES.md](TRIGGER_TYPES.md) for complete details.

### Enforcement

- **SUGGEST**: Inject context before prompt, most common
- **Priority levels**: critical > high > medium > low
- **WARN**: Advisory, rarely used
- **BLOCK**: Not currently implemented (would require PreToolUse hooks)

### Actual Hooks

- **UserPromptSubmit**: skill-activation-prompt.ts (suggest skills)
- **PostToolUse**: post-tool-use-tracker.sh (track file changes)

### Anthropic Best Practices

✅ **500-line rule**: Keep SKILL.md under 500 lines
✅ **Progressive disclosure**: Use reference files for details
✅ **Table of contents**: Add to reference files > 100 lines
✅ **One level deep**: Don't nest references deeply
✅ **Rich descriptions**: Include all trigger keywords (max 1024 chars)
✅ **Test first**: Build 3+ evaluations before extensive documentation
✅ **Gerund naming**: Prefer verb + -ing (e.g., "processing-pdfs")

### Troubleshoot

Test hooks manually:
```bash
# UserPromptSubmit (skill suggestions)
echo '{"prompt":"test"}' | npx tsx .claude/hooks/skill-activation-prompt.ts

# PostToolUse (file tracking)
echo '{"tool_name":"Edit","tool_input":{"file_path":"test.ts"}}' | \
  .claude/hooks/post-tool-use-tracker.sh
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for complete debugging guide.

---

## Related Files

**Configuration:**
- `.claude/skills/skill-rules.json` - Master configuration
- `.claude/hooks/state/` - Session tracking
- `.claude/settings.json` - Hook registration

**Hooks:**
- `.claude/hooks/skill-activation-prompt.ts` - UserPromptSubmit (skill suggestions)
- `.claude/hooks/post-tool-use-tracker.sh` - PostToolUse (file change tracking)

**All Skills:**
- `.claude/skills/*/SKILL.md` - Skill content files

---

**Skill Status**: COMPLETE - Restructured following Anthropic best practices ✅
**Line Count**: < 500 (following 500-line rule) ✅
**Progressive Disclosure**: Reference files for detailed information ✅

**Next**: Create more skills, refine patterns based on usage
