# Skill Catalog

> Canonical skill definitions live in `agents/skills/<name>/SKILL.md`.
> Thin wrappers for Claude Code discovery live in `.claude/skills/<name>/SKILL.md`.

## Available Skills

| Skill | Description | Trigger Phrases |
|-------|-------------|-----------------|
| `project-wiki` | Lint, query, and compile the project knowledge base | "lint KB", "what do we know about X", "compile wiki" |
| `research-intake` | Ingest external sources into structured knowledge base | "research intake", "ingest this", "add to knowledge base" |
| `find-skills` | Discover and install skills from the open ecosystem | "find a skill for X", "search skills" |
| `new-skill` | Scaffold a new skill definition | "create a skill for X" |
| `new-handoff` | Create a structured handoff document | "create handoff", "hand off this work" |
| `safe-commit` | Commit with secret scanning pre-check | "safe commit", "commit with scanning" |
| `simplify` | Review changed code for reuse and quality | "simplify this", "review for simplification" |
| `upstream` | Contribute instance changes back to archetype | "upstream this change" |
| `swarm` | Swarm coordination operations | "swarm status", "claim work" |

## Adding a Skill

1. Create canonical definition at `agents/skills/<name>/SKILL.md`
2. Create thin wrapper at `.claude/skills/<name>/SKILL.md` pointing to the canonical definition
3. Add an entry to this catalog
4. Run `python3 scripts/validate/validate_skills.py` to verify
