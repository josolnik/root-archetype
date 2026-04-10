# Codex Configuration

> Primary instructions: read `AGENT.md` in this directory.
> This file contains Codex/OpenAI-specific wiring only.

## Engine Wiring

- Skills: read directly from `agents/skills/` (no wrapper layer needed)
- Agent roles: `agents/roles/*.md`
- Shared policy: `agents/shared/*.md`

## Hooks

Codex does not currently support hook wiring. Safety hooks in `scripts/hooks/`
can be integrated via CI/CD or pre-commit hooks.
