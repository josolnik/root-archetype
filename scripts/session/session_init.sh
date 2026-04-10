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
    "${REPO_ROOT}/notes"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "Created: $dir"
    fi
done

# --- Check active handoffs ---
ACTIVE_COUNT=$(find "${REPO_ROOT}/notes" -path "*/handoffs/*.md" -not -path "*/completed/*" -not -name "INDEX.md" 2>/dev/null | wc -l)
echo "Active handoffs: ${ACTIVE_COUNT}"

# --- Health summary ---
echo ""
echo "Session ready."
agent_task_end "Session initialization" "success"
