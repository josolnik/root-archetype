#!/bin/bash
set -euo pipefail

# Sync all registered repos — pull latest, rebuild indexes
# Usage: sync-repos.sh [--pull]

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
REPOS_DIR="${ROOT_DIR}/repos"

PULL=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pull) PULL=true; shift ;;
        *) shift ;;
    esac
done

echo "=== Sync Registered Repos ==="

if [[ ! -d "$REPOS_DIR" ]]; then
    echo "No repos directory found."
    exit 0
fi

SYNCED=0
FAILED=0

for repo_path in "$REPOS_DIR"/*/; do
    [[ -d "$repo_path" ]] || continue
    name="$(basename "$repo_path")"

    echo ""
    echo "--- ${name}: ${repo_path} ---"

    if [[ ! -d "${repo_path}/.git" ]]; then
        echo "  SKIP: Not a git repository"
        ((FAILED++))
        continue
    fi

    # Check status
    BRANCH=$(git -C "$repo_path" branch --show-current 2>/dev/null || echo "unknown")
    CLEAN=$(git -C "$repo_path" status --porcelain 2>/dev/null | wc -l)
    echo "  Branch: ${BRANCH}"
    echo "  Uncommitted changes: ${CLEAN}"

    # Pull if requested
    if [[ "$PULL" == "true" && "$CLEAN" -eq 0 ]]; then
        echo "  Pulling..."
        git -C "$repo_path" pull --rebase 2>&1 | sed 's/^/  /' || echo "  Pull failed (non-critical)"
    fi

    ((SYNCED++))
done

echo ""
echo "Synced: ${SYNCED}, Failed: ${FAILED}"

# Rebuild agent registry
echo ""
bash "${ROOT_DIR}/scripts/repos/scan-agents.sh"
