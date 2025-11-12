# Cross-Repo Doc Sync Metrics Dashboard

**Generated:** 2025-11-07T00:29:28Z

---

## Summary (Last 30 Days)

| Metric | Value |
|--------|-------|
| **Total runs** | 1 |
| **Total cost** | $0.286 |
| **Avg cost per run** | $0.286 |
| **Total files modified** | 3 |
| **Cost per file** | $0.095 |

## All-Time Statistics

| Metric | Value |
|--------|-------|
| **Total runs** | 1 |
| **Total cost** | $0.286 |
| **Avg cost per run** | $0.286 |
| **Total commits analyzed** | 14 |
| **Total lines changed** | 11976 |
| **Avg commit size** | 855 lines |
| **Cost per 1K lines** | $0.024 |

---

## Recent Runs (Last 7)

| Date | Duration | Model | Commits | Files | Lines Changed | Tokens | Cost | Task |
|------|----------|-------|---------|-------|---------------|--------|------|------|
| 2025-11-06 | 3338s | opus | 14 | 3 | 11976 | 95K | $0.286 | Example sync run - backend refactor documentation update |

---

## Cost Trends

| Period | Runs | Total Cost | Avg per Run |
|--------|------|------------|-------------|
| **Last 7 days** | 1 | $0.286 | $.286 |
| **Last 30 days** | 1 | $0.286 | $.286 |
| **Projected monthly** | ~0 | ~$.286 | - |

_Based on current usage patterns (0 runs/day)_

---

## Insights

### Efficiency Metrics
- **Avg tokens per file modified**: ~31,733
- **Cost efficiency**: $0.024 per 1,000 lines analyzed
- **Token usage**: Actual usage tracked (95K tokens)

### Commit Analysis
- **Largest commit**: 2,640 lines across 19 files
- **Average commit**: 855 lines
- Larger commits = higher sync costs (more context to analyze)

---

## Cost Optimization Tips

1. **Batch changes**: Fewer, larger syncs are more efficient than many small ones
2. **Target specific repos**: Only sync repos that changed significantly
3. **Monitor trends**: Track cost per 1K lines to identify inefficiencies
4. **Update metrics**: Always update with actual tokens from UI for accuracy

---

## Usage Notes

This is sample data showing typical sync metrics. Your actual runs will appear here after:
1. Making changes in application repositories
2. Invoking cross-repo-doc-sync agent
3. Agent saves metrics to sync-costs.jsonl
4. Dashboard regenerates automatically

**To regenerate this dashboard:**
```bash
./doc-sync-logs/scripts/generate-metrics-dashboard.sh
```

**To update with actual token usage:**
```
Invoke agent with: "Update metrics with actual: [TOKENS] tokens, [SECONDS] seconds"
```

---

_This dashboard provides insights into documentation sync costs and helps optimize your workflow._
