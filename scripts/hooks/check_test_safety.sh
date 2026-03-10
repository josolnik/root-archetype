#!/bin/bash
set -euo pipefail

# Hook: check_test_safety.sh
# Trigger: PreToolUse → Bash
# Purpose: Prevent unbounded test parallelism

MAX_WORKERS="${TEST_MAX_WORKERS:-16}"

# Extract command from tool input
COMMAND=$(cat | jq -r '.command // empty')

if [[ -z "$COMMAND" ]]; then
    exit 0
fi

# Check for pytest with dangerous parallelism
if echo "$COMMAND" | grep -qE 'pytest.*-n\s+auto'; then
    echo "BLOCKED: 'pytest -n auto' would spawn unbounded workers."
    echo "Use 'pytest -n ${MAX_WORKERS}' or fewer."
    exit 2
fi

# Check for pytest -n N where N > MAX_WORKERS
if echo "$COMMAND" | grep -qP "pytest.*-n\s+(\d+)"; then
    N=$(echo "$COMMAND" | grep -oP "(?<=-n\s)\d+" | head -1)
    if [[ -n "$N" && "$N" -gt "$MAX_WORKERS" ]]; then
        echo "BLOCKED: 'pytest -n ${N}' exceeds max workers (${MAX_WORKERS})."
        echo "Use 'pytest -n ${MAX_WORKERS}' or fewer."
        exit 2
    fi
fi

exit 0
