# Engine Adapters

Engine-specific adapter templates. Each subdirectory contains the blueprints
for wiring a particular reasoning engine (Claude Code, Codex, etc.) to the
engine-neutral governance layer in `agents/`, `scripts/`, and `AGENT.md`.

## How It Works

The repo is **engine-neutral at rest** — no engine-specific files are tracked
in git. When a user clones the repo and runs init, they choose an engine:

```bash
./init-project.sh my-project /path/to/project --engine claude
```

The init script calls `scripts/utils/generate-engine.sh`, which:

1. Copies the engine's doc template (`ENGINEDOC.md.tmpl`) to the project root
   (e.g., `CLAUDE.md`)
2. Copies engine-specific config files (e.g., `.claude/settings.json`)
3. Auto-generates skill discovery wrappers from `agents/skills/*/SKILL.md`
   frontmatter (Claude Code only — Codex reads skills directly)

Generated files are gitignored. To regenerate after adding a new skill:

```bash
bash scripts/utils/generate-engine.sh --engine claude
```

## Directory Layout

```
agents/engines/
├── README.md              # This file
├── claude/
│   ├── ENGINEDOC.md.tmpl  # Template for CLAUDE.md
│   ├── settings.json.tmpl # Template for .claude/settings.json
│   ├── commands/           # Command definitions (copied as-is)
│   │   └── simplify.md
│   └── skills/
│       └── README.md       # Documents auto-generation pattern
└── codex/
    ├── ENGINEDOC.md.tmpl  # Template for CODEX.md
    └── README.md          # Codex adapter notes
```

## Adding a New Engine

1. Create `agents/engines/{engine-name}/`
2. Add `ENGINEDOC.md.tmpl` with engine-specific wiring documentation
3. Add any config files the engine requires
4. Update `scripts/utils/generate-engine.sh` with a generation case
5. Update `agents/skills/DISCOVERY.md` with engine discovery instructions
