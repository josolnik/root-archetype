# Agent System

## Architecture: Thin-Map

```
agents/shared/          ← Cross-cutting policy (all roles inherit)
  ├── OPERATING_CONSTRAINTS.md
  ├── ENGINEERING_STANDARDS.md
  └── WORKFLOWS.md

agents/*.md             ← Role-specific overlays (6-section schema)
```

## Adding a New Role

1. Create `agents/your-role.md` with all 6 required sections
2. Run `scripts/validate/validate_agents_structure.py` to verify schema
3. Register the role in the unified agent registry (`scripts/repos/scan-agents.sh`)

## Required Sections

Every role file must contain:

| Section | Purpose |
|---------|---------|
| `## Mission` | One-line role purpose |
| `## Use This Role When` | Trigger conditions |
| `## Inputs Required` | What the role needs to start |
| `## Outputs` | What the role produces |
| `## Workflow` | Step-by-step execution pattern |
| `## Guardrails` | Constraints and safety limits |

## Example Roles

The archetype ships with example roles that can be customized:
- `lead-developer.md` — Architecture decisions, cross-agent coordination
- `research-engineer.md` — Implementation and debugging
- `safety-reviewer.md` — Risk gate for high-impact operations
