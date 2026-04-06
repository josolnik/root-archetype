# Knowledge Base Linter & Governance Hygiene Patterns

**Status**: active
**Created**: 2026-04-06 (via research intake deep-dive)
**Categories**: governance, validation, upstream
**Origin**: intake-268 (Karpathy LLM Wiki), intake-269 (nvk/llm-wiki), intake-270 (tobi/qmd)

## Objective

Upstream knowledge-base hygiene patterns into root-archetype so all instances inherit them. Governance repos are LLM-compiled knowledge bases (Karpathy, intake-268) — they need the same lint operations a wiki does: orphan detection, staleness flagging, contradiction detection, and follow-through validation.

Root-archetype has 5 validators but none that lint the knowledge base itself. This handoff closes that gap and adds skill-template patterns for credibility scoring, anti-confirmation-bias, and session persistence.

---

## Outstanding Tasks (Priority Order)

### Phase 1 — Upstream freshness check (P0)

- [ ] Port `check_handoff_freshness.sh` from epyc-root to `scripts/validate/check_handoff_freshness.sh`
  - Replace hardcoded `/mnt/raid0/llm/epyc-root/handoffs/active` with repo-relative `$(cd "$(dirname "$0")/../.." && pwd)/handoffs/active`
  - Accept `--warn-days N` and `--stale-days N` flags (defaults: 14, 30)
- [ ] Add `knowledge-lint` task to `nightshift.yaml` at priority 4.5 (between doc-drift and docs-backfill)

### Phase 2 — Knowledge base linter (P0)

- [ ] Create `scripts/validate/lint_knowledge_base.py` with 4 lint passes:
  1. **Orphan handoff detection**: parse all `*-index.md` files in `handoffs/active/`, extract referenced handoff filenames via regex, compare against actual files — any file not referenced by any index is orphaned
  2. **Stale handoff flagging**: stat each file, flag >14d as aging, >30d as stale
  3. **Contradictory status detection**: extract `**Status**:` line from each handoff, compare against directory placement (`active/` vs `completed/` vs `blocked/`), flag mismatches
  4. **Un-actioned intake detection**: if `research/intake_index.yaml` exists, find entries with `verdict: worth_investigating` or `verdict: new_opportunity` that have no `handoffs_created` or `handoffs_updated` field and are older than 7 days
- [ ] Register linter in `nightshift.yaml` under the `knowledge-lint` task
- [ ] Add to `CLAUDE.md` validators list

### Phase 3 — Skill template additions (P1)

- [ ] Create `_templates/skill/references/credibility-scoring-rubric.md` with point-based rubric:
  - Peer-reviewed venue: +2
  - Published within 12 months: +1 / older than 24 months: -1
  - Author authority (h-index, affiliation): +1
  - Identified commercial/methodological bias: -1
  - Independent corroboration by other sources: +1 per source (max +2)
  - Tiers: High (4-6), Medium (2-3), Low (0-1), Reject (<0)
- [ ] Add commented anti-confirmation-bias section to `_templates/skill/SKILL.md.template`:
  ```
  <!-- Optional: Anti-confirmation-bias (uncomment for research-oriented skills)
  ## Bias Mitigation
  - After initial assessment, actively search for contradicting evidence
  - If all key claims align with existing work, explicitly search for "{claim} criticism" and "{technique} limitations"
  - Note any contradicting evidence in entry notes with explicit `contradicting_evidence:` field
  -->
  ```

### Phase 4 — Session persistence template (P2)

- [ ] Create `_templates/skill/references/session-persistence-schema.md` documenting the `.research-session.json` pattern:
  - Schema: `{session_id, started_at, last_checkpoint, phase, entries_processed: [], entries_remaining: [], state: {}}`
  - Resume protocol: on skill invocation, check for existing session file, offer to resume or start fresh
  - Staleness: warn if session file >7 days old
  - Nightshift integration: nightshift tasks can check for session file to resume interrupted work

---

## Dependency Graph

```
Phase 1 (freshness check)    ── independent, quick port ──
Phase 2 (linter)             ── independent, main deliverable ──
Phase 3 (skill templates)    ── independent, template additions ──
Phase 4 (session persistence) ── independent, documentation only ──
```

No inter-phase dependencies. All phases can be executed in any order.

---

## Cross-Cutting Concerns

1. **Linter ↔ validate_document_drift.py**: The existing drift validator checks structural requirements (required dirs/files exist, handoff status vs directory). The new linter checks *knowledge quality* (orphans, staleness, contradictions). These are complementary — lint_knowledge_base.py should import nothing from validate_document_drift.py to keep them decoupled.

2. **Freshness check ↔ nightshift**: The freshness check produces a human-readable report. When run as a nightshift task, output should be captured in `logs/nightshift/` and surfaced in the umbrella PR's "needs_review" section.

3. **Intake detection ↔ research skill**: The un-actioned intake lint pass only works if the instance has a `research/intake_index.yaml`. The linter should gracefully skip this pass if the file doesn't exist (not all instances will have research intake).

4. **Upstream from epyc-root**: The freshness check script originates from epyc-root. Once upstreamed, epyc-root should replace its local copy with a symlink or note pointing to the archetype version to avoid drift.

---

## Reporting Instructions

After completing any phase:
1. Check the task checkbox in this handoff
2. Run all existing validators to confirm no regressions: `for f in scripts/validate/*.py; do python3 "$f"; done`
3. Update `progress/YYYY-MM/YYYY-MM-DD.md` in root-archetype

---

## Key File Locations

| Resource | Path |
|----------|------|
| Existing validators | `scripts/validate/validate_*.py` |
| Source freshness check (epyc-root) | `/mnt/raid0/llm/epyc-root/scripts/validate/check_handoff_freshness.sh` |
| Nightshift config | `nightshift.yaml` |
| Skill template | `_templates/skill/SKILL.md.template` |
| Template references dir | `_templates/skill/references/` |
| CLAUDE.md (validators list) | `CLAUDE.md` line 29-34 |

## Research Context

| Intake ID | Title | Relevance | Verdict |
|-----------|-------|-----------|---------|
| intake-268 | LLM Wiki (Karpathy) | high | adopt_patterns |
| intake-269 | nvk/llm-wiki | high | adopt_patterns |
| intake-270 | tobi/qmd | high | adopt_component |

**Key insight**: Governance repos are LLM-compiled knowledge bases. The same hygiene operations that keep a wiki healthy (lint for contradictions, orphans, staleness, gaps) apply directly to handoff-based governance. This handoff operationalizes that insight for root-archetype.
