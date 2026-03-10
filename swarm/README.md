# Swarm Coordination Primitive

SQLite-backed multi-agent coordination for governed, single-machine environments.

Inspired by [agenthub](https://github.com/karpathy/agenthub) but adapted for:
- Governed environments (hooks, validators, schema enforcement)
- Single-machine operation (shared filesystem, not HTTP)
- Inference-bottlenecked workflows (priority scheduling, not FIFO)

## Architecture

```
┌─────────────────────────────────────────┐
│           Coordinator (SQLite)           │
│  ┌──────────┐ ┌────────┐ ┌───────────┐ │
│  │ Work Queue│ │Messages│ │  Locks    │ │
│  │ (priority)│ │(board) │ │  (TTL)   │ │
│  └──────────┘ └────────┘ └───────────┘ │
│  ┌──────────┐ ┌────────┐ ┌───────────┐ │
│  │  Agents  │ │ Budget │ │ Scheduler │ │
│  │(registry)│ │(ledger)│ │   (EI)    │ │
│  └──────────┘ └────────┘ └───────────┘ │
└─────────────────────────────────────────┘
         ▲           ▲           ▲
         │           │           │
    ┌────┴────┐ ┌────┴────┐ ┌───┴─────┐
    │ Worker 1│ │ Worker 2│ │ Worker N│
    │(worktree)│(worktree)│ │(worktree)│
    └─────────┘ └─────────┘ └─────────┘
```

## Components

### Coordinator (`coordinator.py`)
- Agent registration + heartbeat + stale-claim release
- Work queue with priority scoring
- Message board (channels + threaded posts)
- Resource locks with TTL
- Budget enforcement per agent

### Experiment Scheduler (`scheduler.py`)
- Expected Improvement over Pareto hypervolume
- Re-scores all pending experiments after each validation
- Species diversity tracking
- Config novelty computation

### Swarm Client (`client.py`)
- Thin library for agents to interact with coordinator
- Context manager support (auto-start/stop heartbeat)
- Lock tracking and cleanup on exit

## Usage

```python
from swarm import Coordinator, SwarmClient, ExperimentScheduler

# Create coordinator (shared by all agents)
coord = Coordinator("swarm/coordinator.db")

# Create experiment scheduler
scheduler = ExperimentScheduler(coord, objective_names=["quality", "speed"])

# Agent usage
with SwarmClient(coord, name="seeder-1", role="seeder") as client:
    # Submit experiment
    item_id = client.submit_experiment(
        title="Q4_K_M quantization test",
        description="Test Q4_K_M on Qwen3-8B",
        predicted_info_value=0.7,
        predicted_objectives={"quality": 2.5, "speed": 30.0},
        config={"quant": "Q4_K_M", "model": "Qwen3-8B"},
        species="seeder",
    )

    # Claim and execute work
    work = client.claim_work()
    if work:
        # ... do work ...
        client.complete_work(work.item_id, result="success")

    # Use message board
    msg_id = client.post("findings", "Q4_K_M shows 2.5 quality on Qwen3-8B")
    messages = client.read_messages("findings")

    # Acquire resource lock
    if client.acquire_lock("inference_endpoint", ttl_seconds=300):
        try:
            # ... use inference endpoint ...
            pass
        finally:
            client.release_lock("inference_endpoint")
```

## Two-Speed System

The swarm addresses the inference bottleneck:

- **Fast lane**: Workers design experiments, analyze results, propose mutations in parallel (no inference needed)
- **Slow lane**: Validation requires sequential inference endpoint access — one experiment at a time

The scheduler maximizes **Pareto frontier information per unit of inference time**.

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| SQLite-first (no HTTP) | Shared filesystem; <10 agents; WAL mode handles concurrency |
| Priority queue (not FIFO) | Information-gain-aware scheduling maximizes inference utility |
| Worktree isolation | Each agent gets isolated code copy; governance hooks apply per-worktree |
| Dumb coordinator, smart agents | Coordinator stores data; agents make decisions (agenthub philosophy) |
| Budget enforcement | Prevents runaway agents; MetaOptimizer adjusts budgets based on effectiveness |
