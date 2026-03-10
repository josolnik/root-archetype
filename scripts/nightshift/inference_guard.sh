#!/bin/bash
set -euo pipefail

# Inference guard — check if heavy inference is running
# Sets NIGHTSHIFT_INFERENCE_ACTIVE=1 if inference load exceeds threshold
# Sources into run_wrapper.sh

NIGHTSHIFT_INFERENCE_THRESHOLD_GB="${NIGHTSHIFT_INFERENCE_THRESHOLD_GB:-200}"
NIGHTSHIFT_INFERENCE_ACTIVE=0
NIGHTSHIFT_TASK_FILTER=""

# Check llama-server RSS
TOTAL_RSS_GB=0
while read -r pid; do
    RSS_KB=$(awk '/^VmRSS/ {print $2}' "/proc/$pid/status" 2>/dev/null || echo 0)
    RSS_GB=$((RSS_KB / 1048576))
    TOTAL_RSS_GB=$((TOTAL_RSS_GB + RSS_GB))
done < <(pgrep -f "llama-server" 2>/dev/null || true)

if [[ $TOTAL_RSS_GB -ge $NIGHTSHIFT_INFERENCE_THRESHOLD_GB ]]; then
    NIGHTSHIFT_INFERENCE_ACTIVE=1
    NIGHTSHIFT_TASK_FILTER="analysis_only"
    echo "Inference guard: ACTIVE (${TOTAL_RSS_GB}GB >= ${NIGHTSHIFT_INFERENCE_THRESHOLD_GB}GB)"
else
    echo "Inference guard: CLEAR (${TOTAL_RSS_GB}GB < ${NIGHTSHIFT_INFERENCE_THRESHOLD_GB}GB)"
fi

export NIGHTSHIFT_INFERENCE_ACTIVE
export NIGHTSHIFT_TASK_FILTER
