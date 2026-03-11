#!/bin/bash
set -euo pipefail

# Hook: check_filesystem_path.sh
# Trigger: PreToolUse → Write|Edit
# Purpose: Block writes outside approved paths
#
# Configure ALLOWED_PATHS in this script for your project.

ALLOWED_PATHS=(
    # Add project-specific allowed paths here, e.g.:
    # "/home/user/projects/"
    # "/opt/data/"
)

# Always allow .claude config directories
ALWAYS_ALLOWED=(
    "*/.claude/*"
)

# Extract file_path from tool input (passed as JSON on stdin)
FILE_PATH=$(cat | jq -r '.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
    exit 0  # No file_path in input — not our concern
fi

# Check always-allowed patterns
for pattern in "${ALWAYS_ALLOWED[@]}"; do
    if [[ "$FILE_PATH" == $pattern ]]; then
        exit 0
    fi
done

# Check allowed paths
for allowed in "${ALLOWED_PATHS[@]}"; do
    if [[ "$FILE_PATH" == "${allowed}"* ]]; then
        exit 0
    fi
done

echo "BLOCKED: Write to ${FILE_PATH} is outside allowed paths."
echo "Allowed: ${ALLOWED_PATHS[*]}"
exit 2
