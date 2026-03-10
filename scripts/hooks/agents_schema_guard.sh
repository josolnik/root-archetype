#!/bin/bash
set -euo pipefail

# Hook: agents_schema_guard.sh
# Trigger: PreToolUse → Write|Edit
# Purpose: Enforce 6-section schema in agents/*.md files

REQUIRED_SECTIONS=(
    "## Mission"
    "## Use This Role When"
    "## Inputs Required"
    "## Outputs"
    "## Workflow"
    "## Guardrails"
)

# Extract file_path from tool input
FILE_PATH=$(cat | jq -r '.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Only check agents/*.md (not README, AGENT_INSTRUCTIONS, shared/)
if [[ ! "$FILE_PATH" =~ agents/[^/]+\.md$ ]]; then
    exit 0
fi

BASENAME=$(basename "$FILE_PATH")
if [[ "$BASENAME" == "README.md" || "$BASENAME" == "AGENT_INSTRUCTIONS.md" ]]; then
    exit 0
fi

# If file doesn't exist yet, we can't validate — allow creation
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Check for required sections
MISSING=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! rg -q "^${section}" "$FILE_PATH" 2>/dev/null; then
        MISSING+=("$section")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "BLOCKED: agents/*.md file missing required sections:"
    for m in "${MISSING[@]}"; do
        echo "  - $m"
    done
    echo ""
    echo "All role files must contain: ${REQUIRED_SECTIONS[*]}"
    exit 2
fi

exit 0
