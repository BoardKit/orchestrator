#!/bin/bash

# Generate Cross-Repo Doc Sync Metrics Dashboard
# Processes sync-costs.jsonl and creates a markdown summary

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Script is in doc-sync-logs/scripts/, so go up one level to get to doc-sync-logs/
DOC_SYNC_LOGS_DIR="$(dirname "$SCRIPT_DIR")"
METRICS_FILE="$DOC_SYNC_LOGS_DIR/metrics/sync-costs.jsonl"
DASHBOARD_FILE="$DOC_SYNC_LOGS_DIR/metrics/sync-dashboard.md"

# Check if metrics file exists
if [ ! -f "$METRICS_FILE" ]; then
    echo "No metrics file found at: $METRICS_FILE"
    echo "Run the cross-repo-doc-sync agent first to generate metrics."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

echo "Generating metrics dashboard..."

# Calculate date ranges
NOW=$(date -u +%s)
SEVEN_DAYS_AGO=$((NOW - 604800))
THIRTY_DAYS_AGO=$((NOW - 2592000))

# Process metrics
TOTAL_RUNS=$(cat "$METRICS_FILE" | wc -l | tr -d ' ')
LAST_RUN_TIME=$(tail -1 "$METRICS_FILE" | jq -r '.timestamp')

# Calculate totals (all time)
TOTAL_COST=$(jq -s 'map(.cost_usd) | add // 0' "$METRICS_FILE")
AVG_COST=$(jq -s 'if length > 0 then (map(.cost_usd) | add / length) else 0 end' "$METRICS_FILE")
TOTAL_FILES_MODIFIED=$(jq -s 'map(.totals.files_modified) | add // 0' "$METRICS_FILE")
COST_PER_FILE=$(jq -s 'if (map(.totals.files_modified) | add) > 0 then (map(.cost_usd) | add) / (map(.totals.files_modified) | add) else 0 end' "$METRICS_FILE")

# Calculate commit size metrics (all time)
TOTAL_COMMITS=$(jq -s 'map(.totals.commits_analyzed // 0) | add' "$METRICS_FILE")
TOTAL_LINES_CHANGED=$(jq -s 'map(.totals.lines_changed // 0) | add' "$METRICS_FILE")
AVG_COMMIT_SIZE=$(jq -s 'if (map(.totals.commits_analyzed // 0) | add) > 0 then (map(.totals.lines_changed // 0) | add) / (map(.totals.commits_analyzed // 0) | add) | floor else 0 end' "$METRICS_FILE")
COST_PER_1K_LINES_RAW=$(jq -s 'if (map(.totals.lines_changed // 0) | add) > 0 then (map(.cost_usd) | add) / ((map(.totals.lines_changed // 0) | add) / 1000) else 0 end' "$METRICS_FILE")
COST_PER_1K_LINES=$(printf "%.3f" "$COST_PER_1K_LINES_RAW")

# Find largest commit analyzed
LARGEST_COMMIT=$(jq -s 'max_by(.commit_analysis.largest_commit_lines // 0)' "$METRICS_FILE")
LARGEST_COMMIT_LINES=$(echo "$LARGEST_COMMIT" | jq -r '.commit_analysis.largest_commit_lines // 0')
LARGEST_COMMIT_FILES=$(echo "$LARGEST_COMMIT" | jq -r '.commit_analysis.largest_commit_files // 0')
LARGEST_COMMIT_DATE=$(echo "$LARGEST_COMMIT" | jq -r '.timestamp | split("T")[0]')

# Calculate 30-day stats
RUNS_30D=$(jq -s --arg cutoff "$THIRTY_DAYS_AGO" 'map(select((.timestamp | fromdateiso8601) > ($cutoff | tonumber))) | length' "$METRICS_FILE")
COST_30D=$(jq -s --arg cutoff "$THIRTY_DAYS_AGO" 'map(select((.timestamp | fromdateiso8601) > ($cutoff | tonumber))) | map(.cost_usd) | add // 0' "$METRICS_FILE")

# Calculate 7-day stats
RUNS_7D=$(jq -s --arg cutoff "$SEVEN_DAYS_AGO" 'map(select((.timestamp | fromdateiso8601) > ($cutoff | tonumber))) | length' "$METRICS_FILE")
COST_7D=$(jq -s --arg cutoff "$SEVEN_DAYS_AGO" 'map(select((.timestamp | fromdateiso8601) > ($cutoff | tonumber))) | map(.cost_usd) | add // 0' "$METRICS_FILE")

# Calculate projections
if [ "$RUNS_30D" -gt 0 ]; then
    AVG_RUNS_PER_DAY=$(echo "scale=1; $RUNS_30D / 30" | bc)
    PROJECTED_MONTHLY=$(echo "scale=2; $COST_30D" | bc)
else
    AVG_RUNS_PER_DAY="0"
    PROJECTED_MONTHLY="0.00"
fi

# Find most expensive run
MOST_EXPENSIVE=$(jq -s 'max_by(.cost_usd)' "$METRICS_FILE")
MOST_EXP_COST=$(echo "$MOST_EXPENSIVE" | jq -r '.cost_usd')
MOST_EXP_DATE=$(echo "$MOST_EXPENSIVE" | jq -r '.timestamp | split("T")[0]')
MOST_EXP_FILES=$(echo "$MOST_EXPENSIVE" | jq -r '.totals.files_modified')

# Find fastest run
FASTEST=$(jq -s 'min_by(.duration_sec)' "$METRICS_FILE")
FASTEST_TIME=$(echo "$FASTEST" | jq -r '.duration_sec')
FASTEST_FILES=$(echo "$FASTEST" | jq -r '.totals.files_modified')
FASTEST_DATE=$(echo "$FASTEST" | jq -r '.timestamp | split("T")[0]')

# Get recent runs (last 7)
RECENT_RUNS=$(jq -s 'reverse | .[0:7]' "$METRICS_FILE")

# Generate dashboard markdown
cat > "$DASHBOARD_FILE" << 'EOF_HEADER'
# Cross-Repo Doc Sync Metrics Dashboard

**Generated:** TIMESTAMP_PLACEHOLDER

---

## Summary (Last 30 Days)

| Metric | Value |
|--------|-------|
| **Total runs** | RUNS_30D_PLACEHOLDER |
| **Total cost** | $COST_30D_PLACEHOLDER |
| **Avg cost per run** | $AVG_COST_PLACEHOLDER |
| **Total files modified** | TOTAL_FILES_MODIFIED_PLACEHOLDER |
| **Cost per file** | $COST_PER_FILE_PLACEHOLDER |

## All-Time Statistics

| Metric | Value |
|--------|-------|
| **Total runs** | TOTAL_RUNS_PLACEHOLDER |
| **Total cost** | $TOTAL_COST_PLACEHOLDER |
| **Avg cost per run** | $AVG_COST_ALL_PLACEHOLDER |
| **Total commits analyzed** | TOTAL_COMMITS_PLACEHOLDER |
| **Total lines changed** | TOTAL_LINES_CHANGED_PLACEHOLDER |
| **Avg commit size** | AVEG_COMMIT_SIZE_PLACEHOLDER lines |
| **Cost per 1K lines** | $COST_PER_1K_LINES_PLACEHOLDER |

---

## Recent Runs (Last 7)

| Date | Duration | Model | Commits | Files | Lines Changed | Tokens | Cost | Task |
|------|----------|-------|---------|-------|---------------|--------|------|------|
EOF_HEADER

# Add recent runs to table
echo "$RECENT_RUNS" | jq -r '.[] | "| \(.timestamp | split("T")[0]) | \(.duration_sec)s | \(.model // "N/A") | \(.totals.commits_analyzed // 0) | \(.totals.files_modified) | \(.totals.lines_changed // 0) | \(.tokens.total / 1000 | floor)K | $\(.cost_usd) | \(.task) |"' >> "$DASHBOARD_FILE"

# Add trends section
cat >> "$DASHBOARD_FILE" << 'EOF_TRENDS'

---

## Cost Trends

| Period | Runs | Total Cost | Avg per Run |
|--------|------|------------|-------------|
| **Last 7 days** | RUNS_7D_PLACEHOLDER | $COST_7D_PLACEHOLDER | $AVG_7D_PLACEHOLDER |
| **Last 30 days** | RUNS_30D_PLACEHOLDER | $COST_30D_PLACEHOLDER | $AVG_30D_PLACEHOLDER |
| **Projected monthly** | ~PROJ_RUNS_PLACEHOLDER | ~$PROJECTED_MONTHLY_PLACEHOLDER | - |

_Based on current usage patterns (AVG_RUNS_PER_DAY_PLACEHOLDER runs/day)_

---

## Optimization Insights

EOF_TRENDS

# Calculate average tokens per file
AVG_TOKENS_PER_FILE=$(jq -s 'if (map(.totals.files_modified) | add) > 0 then (map(.tokens.total) | add) / (map(.totals.files_modified) | add) | floor else 0 end' "$METRICS_FILE")

# Add insights
cat >> "$DASHBOARD_FILE" << EOF_INSIGHTS
- **Avg tokens per file modified**: ~${AVG_TOKENS_PER_FILE}
- **Avg commit size**: ${AVG_COMMIT_SIZE} lines
- **Cost per 1K lines changed**: \$${COST_PER_1K_LINES}
- **Most expensive run**: \$${MOST_EXP_COST} (${MOST_EXP_FILES} files, ${MOST_EXP_DATE})
- **Largest commit analyzed**: ${LARGEST_COMMIT_LINES} lines (${LARGEST_COMMIT_FILES} files, ${LARGEST_COMMIT_DATE})
- **Fastest run**: ${FASTEST_TIME}s (${FASTEST_FILES} files, ${FASTEST_DATE})

### Recommendations

1. **Batch updates**: Combine multiple small changes to reduce per-run overhead
2. **Selective syncing**: Only analyze repos with actual changes
3. **Review large syncs**: Runs modifying 10+ files may benefit from manual review
4. **Watch commit size**: Large commits (1000+ lines) significantly increase cost
   - Cost scales with lines changed (~2 tokens per line analyzed)
   - Consider batching multiple small commits vs. frequent syncs on large commits
5. **Monitor trends**: If monthly cost exceeds \$5, consider optimizing sync frequency

---

## Quick Stats

\`\`\`
Current pricing: \$3 per 1M tokens (Opus model)
Average cost per run: \$${AVG_COST}
Estimated monthly cost: ~\$${PROJECTED_MONTHLY}
Cost efficiency: \$${COST_PER_FILE} per file modified
\`\`\`

---

_Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_
_Data source: metrics/sync-costs.jsonl (${TOTAL_RUNS} total runs)_
EOF_INSIGHTS

# Replace placeholders
CURRENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sed -i.bak "s/TIMESTAMP_PLACEHOLDER/$CURRENT_TIME/" "$DASHBOARD_FILE"
sed -i.bak "s/RUNS_30D_PLACEHOLDER/$RUNS_30D/" "$DASHBOARD_FILE"
sed -i.bak "s/COST_30D_PLACEHOLDER/$COST_30D/" "$DASHBOARD_FILE"
sed -i.bak "s/AVG_COST_PLACEHOLDER/$AVG_COST/" "$DASHBOARD_FILE"
sed -i.bak "s/TOTAL_FILES_MODIFIED_PLACEHOLDER/$TOTAL_FILES_MODIFIED/" "$DASHBOARD_FILE"
sed -i.bak "s/COST_PER_FILE_PLACEHOLDER/$COST_PER_FILE/" "$DASHBOARD_FILE"
sed -i.bak "s/TOTAL_RUNS_PLACEHOLDER/$TOTAL_RUNS/" "$DASHBOARD_FILE"
sed -i.bak "s/TOTAL_COST_PLACEHOLDER/$TOTAL_COST/" "$DASHBOARD_FILE"
sed -i.bak "s/AVG_COST_ALL_PLACEHOLDER/$AVG_COST/" "$DASHBOARD_FILE"
sed -i.bak "s/TOTAL_COMMITS_PLACEHOLDER/$TOTAL_COMMITS/" "$DASHBOARD_FILE"
sed -i.bak "s/TOTAL_LINES_CHANGED_PLACEHOLDER/$TOTAL_LINES_CHANGED/" "$DASHBOARD_FILE"
sed -i.bak "s/AVEG_COMMIT_SIZE_PLACEHOLDER/$AVG_COMMIT_SIZE/" "$DASHBOARD_FILE"
sed -i.bak "s/COST_PER_1K_LINES_PLACEHOLDER/$COST_PER_1K_LINES/" "$DASHBOARD_FILE"
sed -i.bak "s/RUNS_7D_PLACEHOLDER/$RUNS_7D/" "$DASHBOARD_FILE"
sed -i.bak "s/COST_7D_PLACEHOLDER/$COST_7D/" "$DASHBOARD_FILE"

# Calculate averages for trends section
if [ "$RUNS_7D" -gt 0 ]; then
    AVG_7D=$(echo "scale=3; $COST_7D / $RUNS_7D" | bc)
else
    AVG_7D="0.000"
fi

if [ "$RUNS_30D" -gt 0 ]; then
    AVG_30D=$(echo "scale=3; $COST_30D / $RUNS_30D" | bc)
    PROJ_RUNS=$(echo "scale=0; $RUNS_30D / 30 * 30" | bc)
else
    AVG_30D="0.000"
    PROJ_RUNS="0"
fi

sed -i.bak "s/AVG_7D_PLACEHOLDER/$AVG_7D/" "$DASHBOARD_FILE"
sed -i.bak "s/AVG_30D_PLACEHOLDER/$AVG_30D/" "$DASHBOARD_FILE"
sed -i.bak "s/PROJECTED_MONTHLY_PLACEHOLDER/$PROJECTED_MONTHLY/" "$DASHBOARD_FILE"
sed -i.bak "s/PROJ_RUNS_PLACEHOLDER/$PROJ_RUNS/" "$DASHBOARD_FILE"
sed -i.bak "s/AVG_RUNS_PER_DAY_PLACEHOLDER/$AVG_RUNS_PER_DAY/" "$DASHBOARD_FILE"

# Remove backup file
rm -f "$DASHBOARD_FILE.bak"

echo "✓ Dashboard generated: $DASHBOARD_FILE"
echo ""
echo "Summary:"
echo "  Total runs (all time): $TOTAL_RUNS"
echo "  Last 30 days: $RUNS_30D runs, \$$COST_30D"
echo "  Last 7 days: $RUNS_7D runs, \$$COST_7D"
echo "  Projected monthly: ~\$$PROJECTED_MONTHLY"
