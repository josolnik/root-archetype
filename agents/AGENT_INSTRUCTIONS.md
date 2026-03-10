# Agent Execution Contract

## Non-Negotiables

1. **Storage**: Write only to approved paths (enforced by hooks)
2. **Testing**: Bounded parallelism only (enforced by hooks)
3. **Logging**: All actions logged via `agent_log.sh`
4. **Retries**: Maximum 3 before root-cause analysis
5. **Rollbacks**: Dangerous operations require rollback plan

## Agent Schema

All role files in `agents/*.md` must contain these 6 sections:

```
## Mission
## Use This Role When
## Inputs Required
## Outputs
## Workflow
## Guardrails
```

Enforced by `scripts/hooks/agents_schema_guard.sh`.

## Shared Policy

Cross-cutting policy in `agents/shared/`:
- `OPERATING_CONSTRAINTS.md` — Filesystem, testing, retry limits
- `ENGINEERING_STANDARDS.md` — Code quality, numerics, verification
- `WORKFLOWS.md` — Standard task patterns

## Output Contract

- Structured findings → handoff documents or progress logs
- Code changes → targeted PRs with test coverage
- Audit trail → automatic via agent_log.sh

## Swarm Participation

Agents can participate in swarm coordination by:
1. Registering with the coordinator (`swarm/coordinator.py`)
2. Claiming work items from the priority queue
3. Posting findings to the message board
4. Acquiring resource locks before using shared resources
