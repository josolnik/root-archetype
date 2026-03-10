#!/bin/bash
set -euo pipefail

# System health check — pre-session diagnostics
# Returns 0 if all critical checks pass, 1 if any fail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"

PASS=0
WARN=0
FAIL=0

check_pass() { echo "  PASS: $1"; ((PASS++)); }
check_warn() { echo "  WARN: $1"; ((WARN++)); }
check_fail() { echo "  FAIL: $1"; ((FAIL++)); }

echo "=== Health Check: $(basename "$REPO_ROOT") ==="

# --- Git status ---
if git -C "$REPO_ROOT" rev-parse --git-dir &>/dev/null; then
    check_pass "Git repository valid"
else
    check_fail "Not a git repository"
fi

# --- Required directories ---
for dir in logs handoffs/active agents scripts; do
    if [[ -d "${REPO_ROOT}/${dir}" ]]; then
        check_pass "Directory exists: ${dir}"
    else
        check_fail "Missing directory: ${dir}"
    fi
done

# --- Hooks configured ---
SETTINGS="${REPO_ROOT}/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
    HOOK_COUNT=$(jq '.hooks.PreToolUse | length' "$SETTINGS" 2>/dev/null || echo 0)
    if [[ "$HOOK_COUNT" -gt 0 ]]; then
        check_pass "Hooks configured (${HOOK_COUNT} matchers)"
    else
        check_warn "No hooks configured"
    fi
else
    check_warn "No .claude/settings.json"
fi

# --- Agent files valid ---
if python3 "${REPO_ROOT}/scripts/validate/validate_agents_structure.py" &>/dev/null; then
    check_pass "Agent structure valid"
else
    check_warn "Agent structure validation failed"
fi

# --- Disk space ---
AVAIL_GB=$(df -BG "${REPO_ROOT}" | tail -1 | awk '{print $4}' | tr -d 'G')
if [[ "$AVAIL_GB" -gt 10 ]]; then
    check_pass "Disk space: ${AVAIL_GB}GB available"
else
    check_warn "Low disk space: ${AVAIL_GB}GB available"
fi

# --- Summary ---
echo ""
echo "Results: ${PASS} pass, ${WARN} warn, ${FAIL} fail"

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
