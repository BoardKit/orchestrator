# Hook Mechanisms - Deep Dive

**⚠️ CURRENT IMPLEMENTATION NOTE:**
This orchestrator currently implements:
- ✅ **UserPromptSubmit** hook (skill-activation-prompt.ts) - Implemented and active
- ✅ **PostToolUse** hook (post-tool-use-tracker.sh) - Implemented and active

---

Technical deep dive into how the UserPromptSubmit and PostToolUse hooks work.

## Table of Contents

- [UserPromptSubmit Hook Flow](#userpromptsubmit-hook-flow)
- [PostToolUse Hook Flow](#posttooluse-hook-flow)
- [Performance Considerations](#performance-considerations)

---

## UserPromptSubmit Hook Flow

### Execution Sequence

```
User submits prompt
    ↓
.claude/settings.json registers hook
    ↓
skill-activation-prompt.sh executes
    ↓
npx tsx skill-activation-prompt.ts
    ↓
Hook reads stdin (JSON with prompt)
    ↓
Loads skill-rules.json
    ↓
Matches keywords + intent patterns
    ↓
Groups matches by priority (critical → high → medium → low)
    ↓
Outputs formatted message to stdout
    ↓
stdout becomes context for Claude (injected before prompt)
    ↓
Claude sees: [skill suggestion] + user's prompt
```

### Key Points

- **Exit code**: Always 0 (allow)
- **stdout**: → Claude's context (injected as system message)
- **Timing**: Runs BEFORE Claude processes prompt
- **Behavior**: Non-blocking, advisory only
- **Purpose**: Make Claude aware of relevant skills

### Input Format

```json
{
  "session_id": "abc-123",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/root/git/your-project",
  "permission_mode": "normal",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "how does the layout system work?"
}
```

### Output Format (to stdout)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SKILL ACTIVATION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 RECOMMENDED SKILLS:
  → project-catalog-developer

ACTION: Use Skill tool BEFORE responding
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Claude sees this output as additional context before processing the user's prompt.

---

## PostToolUse Hook Flow

### Execution Sequence

```
User prompt triggers Edit/Write/MultiEdit tool
    ↓
Tool executes successfully
    ↓
.claude/settings.json registers PostToolUse hook
    ↓
post-tool-use-tracker.sh executes
    ↓
Hook reads stdin (JSON with tool_name, tool_input)
    ↓
Extracts file path from tool input
    ↓
Updates session state tracking
    ↓
Stores modified file paths for skill activation
    ↓
Exits with code 0
```

### Key Points

- **Exit code**: Always 0 (informational only)
- **Timing**: Runs AFTER tool execution completes
- **Behavior**: Non-blocking, tracks file changes
- **Purpose**: Provide context for skill activation on next prompt

### Input Format

```json
{
  "session_id": "abc-123",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/root/git/your-project",
  "permission_mode": "normal",
  "hook_event_name": "PostToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/root/git/your-project/form/src/services/user.ts",
    "old_string": "...",
    "new_string": "..."
  }
}
```

### How It Works

1. **File modification detected**:
   - Hook extracts file path from tool input
   - Stores path in session state

2. **Next user prompt**:
   - UserPromptSubmit hook checks modified files
   - Matches against skill-rules.json patterns
   - Suggests relevant skills based on recent changes

---

## Performance Considerations

### Target Metrics

- **UserPromptSubmit**: < 100ms
- **PostToolUse**: < 50ms

### Performance Bottlenecks

1. **Loading skill-rules.json** (every execution)
   - Future: Cache in memory
   - Future: Watch for changes, reload only when needed

2. **Regex matching** (UserPromptSubmit)
   - Intent patterns for skill activation
   - Future: Lazy compile, cache compiled regexes

3. **File path extraction** (PostToolUse)
   - Parsing tool input JSON
   - Minimal overhead

### Optimization Strategies

**Reduce patterns:**
- Use more specific patterns (fewer to check)
- Combine similar patterns where possible

**Intent patterns:**
- More specific = better targeting
- Example: `authentication|auth|login` better than broad patterns

**Session state:**
- Keep state files small
- Clean up old session states periodically


**Related Files:**
- [skill.md](skill.md) - Main skill guide
- [troubleshooting.md](troubleshooting.md) - Debug hook issues
- [skill_rules_reference.md](skill_rules_reference.md) - Configuration reference
