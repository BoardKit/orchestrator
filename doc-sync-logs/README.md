# Cross-Repo Doc Sync Metrics & Logging

This directory contains metrics, reports, and tools for tracking the cross-repo-doc-sync agent's performance and costs.

**Last Updated:** 2025-11-06

---

## Directory Structure

```
doc-sync-logs/
├── README.md                    # This file
├── metrics/
│   ├── sync-costs.jsonl         # Raw metrics data (one JSON per line)
│   └── sync-dashboard.md        # Human-readable metrics dashboard
├── scripts/
│   └── generate-metrics-dashboard.sh  # Dashboard generation script
└── sync-reports/
    └── sync-report-*.md         # Detailed sync reports (one per run)
```

---

## Quick Start

### View the Dashboard

```bash
# From orchestrator root directory
cat doc-sync-logs/metrics/sync-dashboard.md
```

### Regenerate the Dashboard

```bash
# From orchestrator root directory
./doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

**Requirements:**
- `jq` must be installed: `brew install jq` (macOS) or `apt-get install jq` (Linux)

---

## Metrics Tracking

### How Metrics Are Generated

The `cross-repo-doc-sync` agent automatically generates metrics at the end of every sync run:

1. **SYNC MODE**: Agent analyzes repos and updates docs
   - Saves metrics with **estimated** token usage
   - Creates detailed sync report in `sync-reports/`
   - Appends metrics entry to `sync-costs.jsonl`

2. **UPDATE MODE**: Update metrics with actual values from UI
   - User provides actual token count and duration from UI
   - Agent updates the last metrics entry
   - Automatically regenerates dashboard

### Metrics File Format

**Location:** `metrics/sync-costs.jsonl`

**Format:** JSON Lines (JSONL) - one JSON object per line

**Example Entry:**
```json
{
  "timestamp": "2025-11-06T23:18:36Z",
  "duration_sec": 3338,
  "model": "opus",
  "repos": {
    "app": {
      "files_read": 37,
      "files_modified": 0,
      "commits_analyzed": 14,
      "lines_changed": 11976,
      "files_in_commits": 37
    },
    "core": {
      "files_read": 0,
      "files_modified": 0,
      "commits_analyzed": 0,
      "lines_changed": 0,
      "files_in_commits": 0
    },
    "orchestrator": {
      "files_read": 6,
      "files_modified": 3,
      "commits_analyzed": 0,
      "lines_changed": 0,
      "files_in_commits": 0
    }
  },
  "totals": {
    "files_read": 43,
    "files_modified": 3,
    "commits_analyzed": 14,
    "lines_changed": 11976,
    "files_in_commits": 37
  },
  "commit_analysis": {
    "largest_commit_lines": 2640,
    "largest_commit_files": 19,
    "avg_commit_size": 855
  },
  "tokens": {
    "estimated_input": 47452,
    "estimated_output": 2100,
    "total": 95200,
    "actual": true
  },
  "cost_usd": 0.286,
  "task": "Sync orchestrator docs with app polling refactor (Nov 5-6, 2025)",
  "result": "success"
}
```

**Field Descriptions:**

| Field | Description |
|-------|-------------|
| `timestamp` | ISO 8601 UTC timestamp when sync completed |
| `duration_sec` | Actual execution time in seconds |
| `model` | Model used ("opus", "sonnet", "haiku") |
| `repos.{app\|core\|orchestrator}` | Per-repo metrics |
| `totals` | Aggregated metrics across all repos |
| `commit_analysis` | Commit size insights for cost correlation |
| `tokens.actual` | `true` if updated with actual UI values, absent if estimates |
| `cost_usd` | Cost in USD (accurate if tokens.actual=true) |
| `task` | Brief description of what was synced |
| `result` | "success", "partial", or "failed" |

---

## Dashboard

### What's in the Dashboard

The dashboard (`metrics/sync-dashboard.md`) provides:

- **Summary (Last 30 Days)**: Recent activity and costs
- **All-Time Statistics**: Historical trends and totals
- **Recent Runs Table**: Last 7 sync runs with details
- **Cost Trends**: 7-day, 30-day, and projected monthly costs
- **Optimization Insights**: Cost efficiency metrics and recommendations

### Generating the Dashboard

**Run the script:**
```bash
./doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

**What it does:**
1. Reads all entries from `sync-costs.jsonl`
2. Calculates statistics and trends
3. Generates markdown tables and summaries
4. Saves to `metrics/sync-dashboard.md`
5. Prints summary to terminal

**Output Example:**
```
Generating metrics dashboard...
✓ Dashboard generated: /path/to/sync-dashboard.md

Summary:
  Total runs (all time): 1
  Last 30 days: 1 runs, $0.286
  Last 7 days: 1 runs, $0.286
  Projected monthly: ~$0.286
```

### Dashboard Sections Explained

**Recent Runs Table:**
```
| Date       | Duration | Model | Commits | Files | Lines Changed | Tokens | Cost   | Task |
|------------|----------|-------|---------|-------|---------------|--------|--------|------|
| 2025-11-06 | 3338s    | opus  | 14      | 3     | 11976         | 95K    | $0.286 | ... |
```

- **Duration**: Actual execution time (use to predict future runs)
- **Model**: Which Claude model was used
- **Commits**: Number of commits analyzed (correlates with cost)
- **Lines Changed**: Total lines in commits (major cost factor)
- **Tokens**: Actual token usage if updated, estimate otherwise
- **Cost**: Actual cost if tokens updated

---

## Sync Reports

### What Are Sync Reports?

Detailed reports generated for each sync run, saved in `sync-reports/`.

**Filename Format:** `sync-report-YYYY-MM-DD-HHMMSS.md`

**Example:** `sync-report-2025-11-06-231709.md`

### Report Contents

Each report includes:
1. **Changes Detected**: What changed in app/core repos
2. **Documentation Impact**: Which orchestrator docs were affected
3. **Sync Plan**: What updates were needed
4. **Updates Made**: Summary of all changes
5. **Verification Checklist**: Quality checks
6. **Recommendations**: Follow-up actions
7. **Cost Metrics**: Execution time, tokens, cost

### Finding Reports

**List all reports:**
```bash
ls -lt doc-sync-logs/sync-reports/
```

**View latest report:**
```bash
cat doc-sync-logs/sync-reports/$(ls -t doc-sync-logs/sync-reports/ | head -1)
```

**View specific report:**
```bash
cat doc-sync-logs/sync-reports/sync-report-2025-11-06-231709.md
```

---

## Two-Phase Workflow

The cross-repo-doc-sync agent uses a two-phase workflow for accurate cost tracking:

### Phase 1: SYNC MODE (Initial Run)

**Invoke agent:**
```bash
cross-repo-doc-sync agent → "Sync docs for APP changes"
```

**What happens:**
1. Agent analyzes repo changes
2. Updates orchestrator documentation
3. Saves metrics with **estimated** tokens
4. Creates detailed sync report
5. Shows actual token count in UI

**Check UI for:**
- Actual token count (e.g., 95,200 tokens)
- Actual duration (e.g., 3,338 seconds or 55m 38s)

### Phase 2: UPDATE MODE (Update with Actual)

**Re-invoke agent with actual values:**
```bash
cross-repo-doc-sync agent → "Update metrics with actual: 95200 tokens, 3338 seconds"
```

**What happens:**
1. Agent detects UPDATE MODE
2. Reads last metrics entry
3. Updates with actual token count and duration
4. Calculates accurate cost
5. Regenerates dashboard automatically
6. Shows before/after comparison

**Example invocation:**
```
Update metrics with actual: 95200 tokens (90K input, 5.2K output), 3338 seconds
```

**Trigger phrases for UPDATE MODE:**
- "update metrics"
- "actual tokens"
- "actual usage"
- "update with actual"
- Or just provide numbers: "95200 tokens, 3338 seconds"

---

## Cost Analysis

### Understanding Cost Factors

**Major cost drivers:**
1. **Lines changed in commits**: ~2 tokens per line analyzed
2. **Number of commits**: More commits = more git operations
3. **Files modified in orchestrator**: Output tokens for documentation

**Cost per 1K lines changed:**
- Baseline: ~$0.024 per 1,000 lines (based on actual data)
- Varies based on complexity of changes

**Model pricing (as of 2025-11):**
- **Opus**: $15/1M input tokens, $75/1M output tokens

### Optimizing Costs

**Recommendations from dashboard:**
1. **Batch updates**: Combine multiple small changes to reduce per-run overhead
2. **Selective syncing**: Only analyze repos with actual changes
3. **Review large syncs**: Runs modifying 10+ files may benefit from manual review
4. **Watch commit size**: Large commits (1000+ lines) significantly increase cost
5. **Monitor trends**: If monthly cost exceeds $5, consider optimizing sync frequency

**Cost-efficient practices:**
- Sync after batches of commits, not after each commit
- For small docs updates, consider manual editing instead of running agent
- Use agent for complex multi-file syncs where value justifies cost

---

## Troubleshooting

### Dashboard Script Fails

**Error: `jq` command not found**
```bash
# Install jq
brew install jq  # macOS
apt-get install jq  # Linux
```

**Error: No metrics file found**
```
Solution: Run the cross-repo-doc-sync agent at least once to generate metrics
```

### Metrics Entry Malformed

**Symptom:** Dashboard script fails with JSON parsing error

**Solution:**
1. Check `sync-costs.jsonl` for invalid JSON
2. Each line must be valid JSON (no trailing commas)
3. Use `jq` to validate: `cat sync-costs.jsonl | jq .`

**Fix malformed line:**
```bash
# View the file to find bad line
cat sync-costs.jsonl

# Edit directly or remove bad line
# Each line should be a complete JSON object
```

### Dashboard Not Updating

**Check:**
1. Metrics file exists: `ls -la doc-sync-logs/metrics/sync-costs.jsonl`
2. Script is executable: `chmod +x doc-sync-logs/scripts/generate-metrics-dashboard.sh`
3. Run script manually to see errors: `./doc-sync-logs/scripts/generate-metrics-dashboard.sh`

---

## Best Practices

### When to Run Syncs

**Good times to sync:**
- After completing a major feature (multiple commits)
- After refactoring (architectural changes)
- Before context reset (to document current state)
- Weekly/bi-weekly for active development

**Avoid syncing:**
- After every single commit (too frequent, costly)
- For trivial changes (typo fixes, small tweaks)
- When no significant architectural changes occurred

### Maintaining Metrics

**Regular maintenance:**
1. Review dashboard weekly to track trends
2. Update metrics with actual tokens after each sync
3. Archive old sync reports (>90 days) if needed
4. Monitor projected monthly costs

**Clean up (optional):**
```bash
# Archive reports older than 90 days
find doc-sync-logs/sync-reports -name "*.md" -mtime +90 -exec mv {} doc-sync-logs/sync-reports/archive/ \;
```

---

## Files Reference

### Core Files

| File | Purpose | Generated By |
|------|---------|--------------|
| `metrics/sync-costs.jsonl` | Raw metrics data | Agent (automatic) |
| `metrics/sync-dashboard.md` | Human-readable dashboard | Script or UPDATE MODE |
| `sync-reports/sync-report-*.md` | Detailed sync reports | Agent (automatic) |
| `scripts/generate-metrics-dashboard.sh` | Dashboard generator | Manual or UPDATE MODE |

### Directory Permissions

All scripts should be executable:
```bash
chmod +x doc-sync-logs/scripts/*.sh
```

---

## Quick Reference

**View dashboard:**
```bash
cat doc-sync-logs/metrics/sync-dashboard.md
```

**Regenerate dashboard:**
```bash
./doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

**View latest sync report:**
```bash
cat doc-sync-logs/sync-reports/$(ls -t doc-sync-logs/sync-reports/ | head -1)
```

**Check metrics file:**
```bash
cat doc-sync-logs/metrics/sync-costs.jsonl | jq .
```

**Update metrics with actual:**
```bash
# Re-invoke cross-repo-doc-sync agent with:
Update metrics with actual: [TOKENS] tokens, [SECONDS] seconds
```

---

**For more information:**
- Agent documentation: `shared/agents/cross-repo-doc-sync.md`
- Orchestrator docs: `CLAUDE.md`
- Dashboard script: `doc-sync-logs/scripts/generate-metrics-dashboard.sh`


