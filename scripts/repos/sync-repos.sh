#!/bin/bash
set -euo pipefail

# Sync all registered repos — pull latest, rebuild indexes
# Usage: sync-repos.sh [--pull]

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
DEP_MAP="${ROOT_DIR}/.claude/dependency-map.json"

PULL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pull) PULL=true; shift ;;
        *) shift ;;
    esac
done

echo "=== Sync Registered Repos ==="

if [[ ! -f "$DEP_MAP" ]]; then
    echo "No dependency map found."
    exit 1
fi

REPOS=$(jq -r '.repos | to_entries[] | "\(.key)|\(.value.path)"' "$DEP_MAP" 2>/dev/null)

if [[ -z "$REPOS" ]]; then
    echo "No repos registered."
    exit 0
fi

SYNCED=0
FAILED=0

while IFS='|' read -r name path; do
    echo ""
    echo "--- ${name}: ${path} ---"

    if [[ ! -d "$path" ]]; then
        echo "  SKIP: Path does not exist"
        ((FAILED++))
        continue
    fi

    if [[ ! -d "${path}/.git" ]]; then
        echo "  SKIP: Not a git repository"
        ((FAILED++))
        continue
    fi

    # Check status
    BRANCH=$(git -C "$path" branch --show-current 2>/dev/null || echo "unknown")
    CLEAN=$(git -C "$path" status --porcelain 2>/dev/null | wc -l)
    echo "  Branch: ${BRANCH}"
    echo "  Uncommitted changes: ${CLEAN}"

    # Pull if requested
    if [[ "$PULL" == "true" && "$CLEAN" -eq 0 ]]; then
        echo "  Pulling..."
        git -C "$path" pull --rebase 2>&1 | sed 's/^/  /' || echo "  Pull failed (non-critical)"
    fi

    ((SYNCED++))
done <<< "$REPOS"

echo ""
echo "Synced: ${SYNCED}, Failed: ${FAILED}"

# Rebuild agent registry
echo ""
bash "${ROOT_DIR}/scripts/repos/scan-agents.sh"
