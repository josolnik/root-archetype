#!/bin/bash
set -euo pipefail

# Inference/compute guard — check if heavy workloads are running
# Sets NIGHTSHIFT_INFERENCE_ACTIVE=1 if load exceeds threshold
# Sources into run_wrapper.sh
#
# Configure NIGHTSHIFT_HEAVY_PROCESS to match your compute process name.
# Leave empty to skip this check entirely.

NIGHTSHIFT_HEAVY_PROCESS="${NIGHTSHIFT_HEAVY_PROCESS:-}"
NIGHTSHIFT_INFERENCE_THRESHOLD_GB="${NIGHTSHIFT_INFERENCE_THRESHOLD_GB:-50}"
NIGHTSHIFT_INFERENCE_ACTIVE=0
NIGHTSHIFT_TASK_FILTER=""

if [[ -z "$NIGHTSHIFT_HEAVY_PROCESS" ]]; then
    echo "Inference guard: SKIPPED (NIGHTSHIFT_HEAVY_PROCESS not configured)"
    export NIGHTSHIFT_INFERENCE_ACTIVE
    export NIGHTSHIFT_TASK_FILTER
    return 0 2>/dev/null || exit 0
fi

# Check heavy process RSS
TOTAL_RSS_GB=0
while read -r pid; do
    RSS_KB=$(awk '/^VmRSS/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)
    RSS_GB=$((RSS_KB / 1048576))
    TOTAL_RSS_GB=$((TOTAL_RSS_GB + RSS_GB))
done < <(pgrep -f "$NIGHTSHIFT_HEAVY_PROCESS" 2>/dev/null || true)

if [[ $TOTAL_RSS_GB -ge $NIGHTSHIFT_INFERENCE_THRESHOLD_GB ]]; then
    NIGHTSHIFT_INFERENCE_ACTIVE=1
    NIGHTSHIFT_TASK_FILTER="analysis_only"
    echo "Inference guard: ACTIVE (${TOTAL_RSS_GB}GB >= ${NIGHTSHIFT_INFERENCE_THRESHOLD_GB}GB)"
else
    echo "Inference guard: CLEAR (${TOTAL_RSS_GB}GB < ${NIGHTSHIFT_INFERENCE_THRESHOLD_GB}GB)"
fi

export NIGHTSHIFT_INFERENCE_ACTIVE
export NIGHTSHIFT_TASK_FILTER
