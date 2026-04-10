#!/usr/bin/env bash
set -euo pipefail

# Hook: PostToolUse (matcher: Edit|Write)
# Write-time checks for child repos

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd -- "$SCRIPT_DIR/../.." && pwd)}"

source "$PROJECT_DIR/scripts/hooks/lib/hook-utils.sh" 2>/dev/null || true
trap 'hook_fail_open "post-edit-check" "unexpected error"' ERR

INPUT="$(cat)"
TOOL_INPUT="$(echo "$INPUT" | jq -r '.tool_input // empty' 2>/dev/null || echo "{}")"
FILE_PATH="$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null || echo "")"

# Only process files in registered repos
REPO_NAME="$(hook_extract_repo "$FILE_PATH")"
[[ -n "$REPO_NAME" ]] || hook_silent

hook_silent
