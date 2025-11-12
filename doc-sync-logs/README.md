# Cross-Repo Doc Sync Metrics & Logging

**The cross-repo documentation sync is a core feature of the orchestrator.** As your codebase evolves across multiple repositories, keeping documentation synchronized becomes critical. This agent automates that process and provides visibility into its performance through automated metrics tracking and a simple dashboard.

---

## What is cross-repo doc sync?

The `cross-repo-doc-sync` agent monitors git commits across your repositories, analyzes code changes, and updates orchestrator documentation to keep everything aligned with your current implementation.

**When to use:**
- After significant code changes that affect shared patterns or architecture
- When adding new features that need documentation updates
- Periodically (weekly or biweekly) to ensure docs stay current

**How to invoke:** From the orchestrator directory, tell Claude Code:
```
"Sync documentation across repositories"
```

**NOTE: This agent won't activate on its own. You have to invoke it.**

---

## Directory Structure

```
doc-sync-logs/
├── README.md                    # This file
├── metrics/
│   ├── sync-costs.jsonl         # Raw metrics data (one JSON per line)
│   └── sync-dashboard.md        # Metrics dashboard
├── scripts/
│   └── generate-metrics-dashboard.sh  # Dashboard generation script
└── sync-reports/
    └── sync-report-*.md         # Detailed sync reports (one per run)
```

---

## Quick Start

### View the Dashboard

```bash
cat doc-sync-logs/metrics/sync-dashboard.md
```

### Regenerate the Dashboard

```bash
./doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

**Requirements:** `jq` must be installed
```bash
brew install jq  # macOS
apt-get install jq  # Linux
```


---

## Files Explained

### `sync-costs.jsonl`

Contains raw metrics data for each sync run.

**Format**: JSON Lines (one JSON object per line)

Each line represents a single sync run. Example:

```json
{
  "timestamp": "2025-11-05T14:30:22Z",
  "duration_sec": 45,
  "model": "opus",
  "repos": {
    "app": {
      "files_read": 12,
      "commits_analyzed": 3,
      "lines_changed": 1245
    }
  },
  "totals": {
    "files_read": 23,
    "files_modified": 5,
    "commits_analyzed": 5,
    "lines_changed": 1812
  },
  "commit_analysis": {
    "largest_commit_lines": 892,
    "avg_commit_size": 362
  },
  "tokens": {
    "total": 18000,
    "actual": true
  },
  "cost_usd": 0.054,
  "task": "Description of sync",
  "result": "success"
}
```

**Key Fields:**
- `timestamp`: When sync completed (ISO 8601 UTC)
- `duration_sec`: Execution time in seconds
- `model`: Claude model used ("opus", "sonnet", "haiku")
- `repos`: Per-repository metrics
- `totals`: Aggregated metrics across all repos
- `tokens.actual`: `true` if updated with actual UI values
- `cost_usd`: Cost in USD (accurate if tokens.actual=true)

### `sync-dashboard.md`

Auto-generated markdown report showing:
- Summary statistics (last 30 days)
- Recent runs table (last 7)
- Cost trends (7-day, 30-day, projected monthly)
- Optimization insights

### `sync-reports/`

Detailed markdown reports for each sync run: `sync-report-YYYY-MM-DD-HHMMSS.md`

**Contents:**
1. Changes detected in repos
2. Documentation impact analysis
3. Updates made to orchestrator
4. Verification checklist
5. Recommendations
6. Cost metrics

---

## Cost Details

Currently the agent is set to Opus model.
**Model pricing (Opus):** $15/1M input tokens, $75/1M output tokens

**NOTE:** Agent pricing is hardcoded in `shared/agents/cross-repo-doc-sync.md`. Update if using other models.


---

## How Metrics Work

The agent **automatically** handles all metrics tracking:

1. Agent starts sync
2. Analyzes repos and updates documentation
3. Tracks all file operations
4. Completes the job and Claude returns token usage estimates
5. Agent reinvoke itself and **Automatically appends metrics** to `sync-costs.jsonl`
6. Creates detailed sync report

No manual intervention needed - metrics are captured automatically.


---

## Troubleshooting

### Dashboard Script Fails

**Error: `jq` command not found**
```bash
brew install jq  # macOS
apt-get install jq  # Linux
```

**Error: No metrics file found**

Solution: Run the cross-repo-doc-sync agent at least once. It will create `sync-costs.jsonl` automatically.

### Invalid JSON in metrics file

Check for malformed entries:
```bash
cat doc-sync-logs/metrics/sync-costs.jsonl | jq -c . > /dev/null
```

Each line must be valid JSON (no trailing commas).

### Dashboard not updating

1. Check metrics file exists: `ls -la doc-sync-logs/metrics/sync-costs.jsonl`
2. Check script is executable: `chmod +x doc-sync-logs/scripts/generate-metrics-dashboard.sh`
3. Run manually to see errors: `./doc-sync-logs/scripts/generate-metrics-dashboard.sh`

---

## Best Practices

**When to run syncs:**
- After completing a major feature (multiple commits)
- After refactoring (architectural changes)
- Before context reset (to document current state)
- Weekly/bi-weekly for active development


---

## More Information

- **Agent documentation**: `shared/agents/cross-repo-doc-sync.md`
- **Orchestrator context**: `CLAUDE.md`
- **Dashboard script**: `doc-sync-logs/scripts/generate-metrics-dashboard.sh`

---

**Last Updated**: 2025-11-12
