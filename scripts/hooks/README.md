# Hooks

All hooks live in `scripts/hooks/`. Claude Code wiring in `.claude/settings.json`
points to paths here.

## Default Hooks (wired in settings.json)

| Hook | Event | Description |
|------|-------|-------------|
| `session-start.sh` | SessionStart | Resolve user, create branch, per-user dirs, load facts |
| `session-end.sh` | SessionEnd | Write progress, push logs, commit session work |
| `check_secrets_read.sh` | PreToolUse (Read/Glob/Grep/Bash) | Block reads of protected paths |
| `check_filesystem_path.sh` | PreToolUse (Write/Edit) | Prevent writes outside project |
| `post-tool-use-audit.sh` | PostToolUse | Append-only audit trail logging |

## Optional Hooks (shipped but not wired by default)

| Hook | Event | Description |
|------|-------|-------------|
| `pre-edit-guard.sh` | PreToolUse (Write/Edit) | Secret scan + log isolation + config tamper-proofing |
| `post-edit-check.sh` | PostToolUse (Edit/Write) | Post-edit validation for child repos |
| `correction-detection.sh` | UserPromptSubmit | Detect user corrections for learning |
| `subagent-start.sh` | SubagentStart | Inject context into subagent sessions |
| `check_test_safety.sh` | PreToolUse (Bash) | Bounded test parallelism |
| `agents_schema_guard.sh` | PreToolUse (Write/Edit) | 6-section agent schema enforcement |
| `agents_reference_guard.sh` | PreToolUse (Write/Edit) | Agent reference validation |
| `skill_usage_log.sh` | PreToolUse (Skill) | Skill usage logging |

## Shared Library

`scripts/hooks/lib/` contains shared utilities:

- `hook-utils.sh` — Common functions (hook_silent, hook_block, hook_warn, hook_load_identity, etc.)
- `session-counters.sh` — Per-session dedup counters
- `secret-patterns.txt` — Shared secret detection patterns (tab-separated: label, regex, replacement)

## Enabling Optional Hooks

Add entries to `.claude/settings.json` following the patterns in the default hooks.
The init wizard (`--guided` mode) provides an interactive hook selection menu.
