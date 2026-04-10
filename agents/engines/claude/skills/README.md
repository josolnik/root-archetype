# Claude Code Skill Wrappers

Skill wrappers in `.claude/skills/{name}/SKILL.md` are **auto-generated** by
`scripts/utils/generate-engine.sh`. Do not create or edit them manually.

## How generation works

The script scans each directory in `agents/skills/` for a `SKILL.md` file,
extracts `name` and `description` from its YAML frontmatter, and writes a
thin wrapper at `.claude/skills/{name}/SKILL.md`:

```yaml
---
name: {extracted name}
description: {extracted description}
---

<!-- Engine wrapper: Claude Code skill discovery -->
<!-- Full methodology: agents/skills/{name}/SKILL.md -->

Read and follow the instructions in `agents/skills/{name}/SKILL.md`.
```

## When to regenerate

Run `bash scripts/utils/generate-engine.sh --engine claude` after:
- Adding a new skill to `agents/skills/`
- Changing a skill's `name` or `description` frontmatter
- Deleting a skill
