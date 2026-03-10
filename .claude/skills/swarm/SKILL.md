# Swarm Coordination Skill

## Description

Launch and manage swarm agent coordination for multi-agent parallel work.

## Commands

### `/swarm status`
Show coordinator status: active agents, pending work, held locks.

### `/swarm start --workers N`
Start a swarm session with N worker agents.

### `/swarm submit "title" --priority P`
Submit a work item to the swarm queue.

### `/swarm messages [channel]`
View recent messages on the swarm message board.

## Workflow

1. **Initialize**: Start coordinator and register workers
2. **Submit work**: Add work items to the priority queue
3. **Workers claim**: Each worker claims and executes the highest-priority item
4. **Post findings**: Workers share results on the message board
5. **Coordinate**: Use locks for shared resources, messages for async communication
6. **Complete**: All work items resolved, consolidated report generated

## Implementation

The swarm primitive lives in `swarm/`:
- `coordinator.py` — SQLite-backed state management
- `scheduler.py` — Information-gain-aware experiment prioritization
- `client.py` — Thin agent client library

## Usage from Python

```python
from swarm import Coordinator, SwarmClient

coord = Coordinator("swarm/coordinator.db")
with SwarmClient(coord, name="worker-1", role="developer") as client:
    work = client.claim_work()
    if work:
        # Execute work...
        client.complete_work(work.item_id, result="done")
```
