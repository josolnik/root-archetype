# /swarm — Swarm Coordination

Manage the swarm coordinator for multi-agent parallel work.

## Usage

- `/swarm status` — Show coordinator stats
- `/swarm start --workers N` — Launch swarm with N workers
- `/swarm submit "title"` — Add work item to queue
- `/swarm messages` — View message board

## Steps

1. Check if coordinator database exists at `swarm/coordinator.db`
2. If not, initialize with `from swarm import Coordinator; Coordinator()`
3. Execute the requested swarm operation
4. Report status to user

## Notes

- The coordinator uses SQLite with WAL mode for concurrent access
- Workers should run in separate worktrees for isolation
- Use resource locks before accessing shared resources (inference endpoint, git operations)
- The experiment scheduler re-scores all pending items after each validation
