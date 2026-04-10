#!/bin/bash
set -euo pipefail

# Register a child repo with the root governance repo
# Usage: register-repo.sh <name> <path> [--purpose "description"]

usage() {
    echo "Usage: $0 <name> <path> [--purpose \"description\"]"
    echo ""
    echo "  name     Short identifier for the repo"
    echo "  path     Absolute path to the repo"
    echo "  --purpose  Optional description of the repo's role"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

REPO_NAME="$1"
REPO_PATH="$2"
shift 2

PURPOSE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --purpose) PURPOSE="$2"; shift 2 ;;
        *) echo "Unknown: $1"; usage ;;
    esac
done

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
REPOS_DIR="${ROOT_DIR}/repos"

# Source logging if available
if [[ -f "${ROOT_DIR}/scripts/utils/agent_log.sh" ]]; then
    source "${ROOT_DIR}/scripts/utils/agent_log.sh"
    agent_task_start "Register repo: ${REPO_NAME}" "Path: ${REPO_PATH}"
fi

echo "=== Registering repo: ${REPO_NAME} ==="
echo "Path: ${REPO_PATH}"

# --- Validate path ---
if [[ ! -d "$REPO_PATH" ]]; then
    echo "WARNING: Path ${REPO_PATH} does not exist yet. Registering anyway."
fi

# --- Create symlink in repos/ ---
mkdir -p "$REPOS_DIR"
if [[ -L "${REPOS_DIR}/${REPO_NAME}" ]]; then
    echo "Symlink already exists, updating..."
    rm "${REPOS_DIR}/${REPO_NAME}"
fi
ln -s "$REPO_PATH" "${REPOS_DIR}/${REPO_NAME}"
echo "Linked: repos/${REPO_NAME} → ${REPO_PATH}"

# --- Seed agent files if missing ---
if [[ -d "$REPO_PATH" ]]; then
    # Seed CLAUDE.md if missing
    if [[ ! -f "${REPO_PATH}/CLAUDE.md" ]]; then
        cat > "${REPO_PATH}/CLAUDE.md" << CLAUDE_EOF
# ${REPO_NAME}

## Purpose

${PURPOSE:-Configure this repo's purpose.}

## Code Style

- Follow existing project conventions
- Run validation after producing artifacts
CLAUDE_EOF
        echo "Seeded: ${REPO_PATH}/CLAUDE.md"
    fi

    # Seed .claude/settings.json if missing
    if [[ ! -f "${REPO_PATH}/.claude/settings.json" ]]; then
        mkdir -p "${REPO_PATH}/.claude"
        cat > "${REPO_PATH}/.claude/settings.json" << SETTINGS_EOF
{
  "hooks": {
    "PreToolUse": []
  }
}
SETTINGS_EOF
        echo "Seeded: ${REPO_PATH}/.claude/settings.json"
    fi

    # Seed agents directory if missing
    if [[ ! -d "${REPO_PATH}/agents" ]]; then
        mkdir -p "${REPO_PATH}/agents"
        cat > "${REPO_PATH}/agents/developer.md" << AGENT_EOF
# Developer

## Mission

General development work for ${REPO_NAME}.

## Use This Role When

- Implementing features or fixes in this repo
- Reviewing or refactoring code

## Inputs Required

- Task description or issue reference
- Relevant codebase context

## Outputs

- Code changes with tests
- Documentation updates

## Workflow

1. Understand the task
2. Implement changes
3. Test and verify
4. Document

## Guardrails

- Follow project code style
- Run tests before committing
- Keep changes focused
AGENT_EOF
        echo "Seeded: ${REPO_PATH}/agents/developer.md"
    fi
fi

echo ""
echo "Repo '${REPO_NAME}' registered successfully."
echo "Run 'scripts/repos/scan-agents.sh' to rebuild the unified agent registry."

if type agent_task_end &>/dev/null; then
    agent_task_end "Register repo: ${REPO_NAME}" "success"
fi
