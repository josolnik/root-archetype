#!/bin/bash
set -euo pipefail

# Session initialization script
# Sources agent logging and verifies environment

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"

# Source agent logging
source "${REPO_ROOT}/scripts/utils/agent_log.sh"
agent_session_start "Session initialization"

echo "=== Session Init: $(basename "$REPO_ROOT") ==="

# --- Verify required directories ---
REQUIRED_DIRS=(
    "${REPO_ROOT}/logs"
    "${REPO_ROOT}/handoffs/active"
    "${REPO_ROOT}/progress"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "Created: $dir"
    fi
done

# --- Check for registered child repos ---
DEP_MAP="${REPO_ROOT}/.claude/dependency-map.json"
if [[ -f "$DEP_MAP" ]]; then
    REPO_COUNT=$(jq '.repos | length' "$DEP_MAP" 2>/dev/null || echo 0)
    echo "Registered repos: ${REPO_COUNT}"
    if [[ "$REPO_COUNT" -gt 0 ]]; then
        jq -r '.repos | to_entries[] | "  \(.key): \(.value.path)"' "$DEP_MAP" 2>/dev/null || true
    fi
fi

# --- Check active handoffs ---
ACTIVE_COUNT=$(find "${REPO_ROOT}/handoffs/active" -name "*.md" 2>/dev/null | wc -l)
echo "Active handoffs: ${ACTIVE_COUNT}"

# --- Health summary ---
echo ""
echo "Session ready."
agent_task_end "Session initialization" "success"
