# Codex Engine Adapter

Codex reads skill definitions directly from `agents/skills/` — no wrapper
layer is needed. The only generated file is `CODEX.md` at the project root.

## What gets generated

- `CODEX.md` — engine-specific wiring doc (from `ENGINEDOC.md.tmpl`)

## No hooks support

Codex does not currently support hook wiring. Safety hooks from
`scripts/hooks/` can be integrated through CI/CD pipelines or
pre-commit hooks instead.
