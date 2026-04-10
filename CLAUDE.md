# {{PROJECT_NAME}} — AI Assistant Guide

## Purpose

Umbrella repository for cross-repo coordination and governance. No application code lives here.

## Repository Map

| Repo | Path | Purpose |
|------|------|---------|
| {{PROJECT_NAME}} (this) | `{{PROJECT_ROOT}}` | Governance, agents, hooks, notes, knowledge |
{{REPO_MAP_ROWS}}

## Governance Infrastructure

### Hooks (`scripts/hooks/`)
Pre/post tool-use hooks for Claude Code sessions:
- Filesystem path safety (`check_filesystem_path.sh`)
- Agent schema validation (`agents_schema_guard.sh`)
- Agent reference validation (`agents_reference_guard.sh`)
- Test safety (`check_test_safety.sh`)
- Skill usage logging (`skill_usage_log.sh`)

### Secrets Protection (`secrets/`)
Convention for sensitive data that must never be read by AI agents:
- `secrets/` directory: gitkepped but contents gitignored
- `secrets/.secretpaths`: configurable list of protected path patterns
- `scripts/hooks/check_secrets_read.sh` hook: blocks Read/Glob/Grep/Bash access to protected paths
- Sandbox (`.claude/settings.local.json`): OS-level filesystem isolation via bubblewrap

### Validators (`scripts/validate/`)
- Agent structure validation (`validate_agents_structure.py`)
- Reference integrity (`validate_agents_references.py`)
- CLAUDE.md matrix consistency (`validate_claude_md_consistency.py`)
- Document drift detection (`validate_document_drift.py`)
- Skills validation (`validate_skills.py`)

### Agent System (`agents/`)
Thin-map architecture:
- `shared/` — Cross-cutting policy (operating constraints, engineering standards, workflows)
- `roles/` — Per-agent specialization files (6-section schema)

### Skills (`.claude/skills/`)
Reusable skill definitions for common workflows:
- Code simplification review (`simplify/`)
- Skill scaffolding (`new-skill/`)
- Handoff creation (`new-handoff/`)
- Safe commit with secret scanning (`safe-commit/`)
- Project wiki maintenance (`project-wiki/`)

### Commands (`.claude/commands/`)
Slash command definitions for Claude Code sessions:
- `/simplify` — Review changed code for reuse, quality, and efficiency (`simplify.md`)

## Notes & Handoffs

- `notes/<user>/handoffs/` — Active work items per user
- `notes/<user>/handoffs/completed/` — Completed handoffs
- `notes/handoffs/INDEX.md` — Aggregation index

## Progress Tracking

Daily progress in `logs/progress/<user>/YYYY-MM/YYYY-MM-DD.md`.

## Agent Logging

```bash
source scripts/utils/agent_log.sh
agent_session_start "Session purpose"
agent_task_start "Description" "Reasoning"
agent_task_end "Description" "success|failure"
```

Audit trail in `logs/agent_audit.log`. Analysis: `scripts/utils/agent_log_analyze.sh --summary`.

## Session Management

- `scripts/session/session_init.sh` — Initialize session, verify environment
- `scripts/session/health_check.sh` — System health diagnostics

## Child Repo Management

- `scripts/repos/register-repo.sh` — Register child repo, seed agent files if missing
- `scripts/repos/scan-agents.sh` — Discover agents across all registered repos
- `scripts/repos/sync-repos.sh` — Pull all registered repos, rebuild indexes

## Code Style

- Shell: `#!/bin/bash` with `set -euo pipefail`
- Always log actions via agent_log.sh
- Run validation after producing artifacts
