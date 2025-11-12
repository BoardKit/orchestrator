# Cross-Repo Doc Sync Metrics

This directory contains automated cost tracking for the cross-repo-doc-sync agent.

## Files

### `sync-costs.jsonl`
**Format**: JSON Lines (one JSON object per line)

Each line represents a single sync run with the following structure:

```json
{
  "timestamp": "2025-11-05T14:30:22Z",
  "duration_sec": 45,
  "repos": {
    "app": {
      "files_read": 12,
      "files_modified": 0,
      "commits_analyzed": 3,
      "lines_changed": 1245,
      "files_in_commits": 8
    },
    "core": {
      "files_read": 8,
      "files_modified": 0,
      "commits_analyzed": 2,
      "lines_changed": 567,
      "files_in_commits": 5
    },
    "orchestrator": {
      "files_read": 3,
      "files_modified": 5,
      "commits_analyzed": 0,
      "lines_changed": 0,
      "files_in_commits": 0
    }
  },
  "totals": {
    "files_read": 23,
    "files_modified": 5,
    "commits_analyzed": 5,
    "lines_changed": 1812,
    "files_in_commits": 13
  },
  "commit_analysis": {
    "largest_commit_lines": 892,
    "largest_commit_files": 6,
    "avg_commit_size": 362
  },
  "tokens": {
    "estimated_input": 15000,
    "estimated_output": 3000,
    "total": 18000
  },
  "cost_usd": 0.054,
  "task": "SSE to polling migration",
  "result": "success"
}
```

**Field Descriptions**:
- `timestamp`: ISO 8601 timestamp when sync completed
- `duration_sec`: Estimated execution time in seconds
- `repos`: Per-repository breakdown of file operations
  - `files_read`: Number of files read during analysis
  - `files_modified`: Number of files modified in orchestrator
  - `commits_analyzed`: Number of git commits analyzed
  - `lines_changed`: Total lines added + deleted in commits (additions + deletions)
  - `files_in_commits`: Number of files changed in commits
- `totals`: Aggregate counts across all repos
- `commit_analysis`: Analysis of commit sizes
  - `largest_commit_lines`: Largest single commit (lines changed)
  - `largest_commit_files`: Files changed in largest commit
  - `avg_commit_size`: Average lines per commit
- `tokens`: Token usage estimates (input, output, total)
- `cost_usd`: Estimated cost in USD (based on $3/1M tokens)
- `task`: Brief description of what was synced
- `result`: "success", "partial", or "failed"

### `sync-dashboard.md`
**Format**: Markdown report

Auto-generated summary dashboard showing:
- Summary statistics (last 30 days)
- Recent runs table
- Cost trends (weekly, monthly, projected)
- Optimization insights

Regenerate with: `bash doc-sync-logs/scripts/generate-metrics-dashboard.sh`

## Automation

The cross-repo-doc-sync agent **automatically** appends metrics to `sync-costs.jsonl` at the end of every run. No manual intervention needed.

## Analyzing Metrics

### View Recent Runs
```bash
tail -5 doc-sync-logs/metrics/sync-costs.jsonl | jq .
```

### Calculate Total Cost (Last 30 Days)
```bash
jq -s 'map(select(.timestamp > (now - 2592000 | strftime("%Y-%m-%dT%H:%M:%SZ")))) | map(.cost_usd) | add' doc-sync-logs/metrics/sync-costs.jsonl
```

### Find Most Expensive Run
```bash
jq -s 'max_by(.cost_usd)' doc-sync-logs/metrics/sync-costs.jsonl
```

### Average Cost Per Run
```bash
jq -s 'map(.cost_usd) | add / length' doc-sync-logs/metrics/sync-costs.jsonl
```

### Group by Task
```bash
jq -s 'group_by(.task) | map({task: .[0].task, runs: length, total_cost: map(.cost_usd) | add})' doc-sync-logs/metrics/sync-costs.jsonl
```

### Commit Size Analysis

#### Cost per 1K Lines Changed
```bash
jq -s 'map(select(.totals.lines_changed > 0) | {task, lines: .totals.lines_changed, cost: .cost_usd, cost_per_1k: (.cost_usd / (.totals.lines_changed / 1000))})' doc-sync-logs/metrics/sync-costs.jsonl
```

#### Average Commit Size
```bash
jq -s 'map(.commit_analysis.avg_commit_size) | add / length' doc-sync-logs/metrics/sync-costs.jsonl
```

#### Largest Commits Analyzed
```bash
jq -s 'sort_by(.commit_analysis.largest_commit_lines) | reverse | .[0:5] | map({task, largest_commit: .commit_analysis.largest_commit_lines, files: .commit_analysis.largest_commit_files, cost: .cost_usd})' doc-sync-logs/metrics/sync-costs.jsonl
```

#### Correlation: Lines vs Cost
```bash
jq -s 'map({lines: .totals.lines_changed, cost: .cost_usd}) | sort_by(.lines)' doc-sync-logs/metrics/sync-costs.jsonl
```

## Budget Tracking

Current pricing: **$3 per 1M tokens** (Opus model)

### Monthly Budget Estimate
Based on daily sync runs:
- 1 run/day × 30 days = 30 runs/month
- Avg cost per run: ~$0.05
- **Monthly estimate**: ~$1.50

### Cost Optimization Tips

1. **Run selectively**: Only sync when significant changes occur
2. **Batch changes**: Sync multiple changes together instead of per-commit
3. **Targeted analysis**: Specify which repos to analyze (app, core, or both)
4. **Review file counts**: High file counts indicate broad changes that may need manual review
5. **Monitor commit size**: Large commits (1000+ lines) significantly increase cost
   - Cost scales with lines changed (~2 tokens per line)
   - A 5000-line commit can cost 3-5x more than a 500-line commit
6. **Batch small commits**: Analyzing 5 small commits together is cheaper than 5 separate syncs

## Dashboard Generation

Regenerate the dashboard to see updated stats:

```bash
bash doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

The dashboard provides:
- 30-day summary
- Recent runs table (last 7)
- Cost trends
- Optimization insights

## Integration

The metrics system is integrated into the cross-repo-doc-sync agent workflow:

1. Agent starts sync
2. Agent performs analysis and updates
3. Agent tracks all file operations
4. Agent estimates tokens and cost
5. **Agent automatically appends metrics** to `sync-costs.jsonl`
6. Agent includes metrics in sync report

No additional steps required - metrics are captured automatically.

## Data Retention

**Recommendation**: Keep at least 90 days of metrics for trend analysis.

To archive old metrics:
```bash
# Archive metrics older than 90 days
jq -s 'map(select(.timestamp > (now - 7776000 | strftime("%Y-%m-%dT%H:%M:%SZ"))))' \
  doc-sync-logs/metrics/sync-costs.jsonl > doc-sync-logs/metrics/sync-costs-recent.jsonl
mv doc-sync-logs/metrics/sync-costs.jsonl doc-sync-logs/metrics/archive/sync-costs-$(date +%Y%m%d).jsonl
mv doc-sync-logs/metrics/sync-costs-recent.jsonl doc-sync-logs/metrics/sync-costs.jsonl
```

## Troubleshooting

### Metrics file doesn't exist
On first run, the agent will create `sync-costs.jsonl` automatically.

### Invalid JSON in metrics file
Check for malformed entries:
```bash
cat doc-sync-logs/metrics/sync-costs.jsonl | jq -c . > /dev/null
```

### Dashboard not updating
Regenerate manually:
```bash
bash doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

### Cost estimates seem off
Token estimates are approximate. For accurate tracking, compare with actual Claude API usage logs if available.

---

**Last Updated**: 2025-11-05
