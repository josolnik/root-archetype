# Claude Code Configuration

> Primary instructions: read `AGENT.md` in this directory.
> This file contains Claude Code-specific wiring only.

## Engine Wiring

- Settings: `.claude/settings.json` — hook paths, permissions
- Skills: `.claude/skills/` — thin wrappers referencing `agents/skills/`
- Local overrides: `.claude/settings.local.json` (gitignored)

## Skill Discovery

Claude Code discovers skills via `.claude/skills/{name}/SKILL.md`.
Engine-neutral skill content lives in `agents/skills/{name}/SKILL.md`.
Claude wrappers include the engine-neutral content via reference.

## Hooks

All hooks live in `scripts/hooks/`. Claude wiring in `.claude/settings.json`
points to those paths. Policy hooks in `.claude/hooks/` handle session lifecycle,
edit guards, and subagent context injection.
