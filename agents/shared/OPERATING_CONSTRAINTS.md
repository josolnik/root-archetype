# Operating Constraints

Shared constraints for all agent roles in this project.

## Filesystem and Storage

- All artifacts must be written under the project root or approved paths
- Environment variables for caches (HF_HOME, PIP_CACHE_DIR, TMPDIR) should be configured in session_init.sh
- Never write to system directories without explicit approval

## Test Safety

- Never run tests with unbounded parallelism (e.g., `pytest -n auto` on high-core machines)
- Maximum test worker count: 16 (configurable per project)
- Enforced by hook: `scripts/hooks/check_test_safety.sh`

## Logging and Traceability

- Source `scripts/utils/agent_log.sh` for all operational tasks
- Record task start/end, decisions, rollback commands
- Append-only audit log in `logs/agent_audit.log`

## Retry Policy

- Maximum 3 retries for failing commands
- After 3 failures: root-cause analysis required
- Do not retry in a tight loop — diagnose first

## Dangerous Operations

Require explicit confirmation + rollback planning:
- Recursive deletes in data/model directories
- System-level privileged changes
- Force-push or destructive git operations
