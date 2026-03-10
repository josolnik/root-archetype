# {{PROJECT_NAME}} — Operational Specification

## Logging Requirements

- Format: JSONL, append-only to `logs/agent_audit.log`
- Required events: TASK_START, TASK_END, CMD_INTENT, CMD_RESULT, FILE_MODIFY, DECISION, ERROR
- Session tracking with 4-hour staleness

## Loop Prevention

- Maximum 3 retries for any failing command
- After 3 failures: root-cause analysis required, not retry

## Hook Table

| Hook | Trigger | Enforces |
|------|---------|----------|
| check_filesystem_path.sh | Write\|Edit | Path safety |
| agents_schema_guard.sh | Write\|Edit | 6-section schema in agents/*.md |
| agents_reference_guard.sh | Write\|Edit | Markdown reference validity |
| check_test_safety.sh | Bash | Test runner safety (bounded workers) |

## Permissions

- Filesystem: Write only to approved paths
- Git: No force-push without explicit approval
- Testing: Bounded worker counts only

## Swarm Coordination

- Coordinator: SQLite with WAL mode (shared filesystem access)
- Work queue: Priority-scored, not FIFO
- Resource locks: TTL-based with heartbeat
- Message board: Channel-scoped, threaded posts
