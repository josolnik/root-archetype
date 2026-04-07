# Credibility Scoring Rubric

Score source credibility on a 0-6 point scale. Record as `credibility_score` (integer or null).

## Scoring Criteria

| Criterion | Points | Notes |
|-----------|--------|-------|
| Peer-reviewed venue (top conference/journal) | +2 | NeurIPS, ICML, ACL, AAAI, Nature, etc. |
| Published within 12 months | +1 | Recency bonus |
| Published > 24 months ago | -1 | Staleness penalty |
| Author authority (major lab, known contributor) | +1 | Google, Meta, academic PI, etc. |
| Identified bias (commercial promotion, conflict of interest) | -1 | Product marketing, benchmark gaming |
| Independent corroboration (other papers/repos confirm results) | +1/source | Max +2 |

## Tiers

| Tier | Score | Interpretation |
|------|-------|---------------|
| High | 4-6 | Strong source, trust claims directly |
| Medium | 2-3 | Reasonable source, verify key claims |
| Low | 0-1 | Weak source, treat as hypothesis only |

## When to Skip

Set `credibility_score: null` for:
- Repository links (repos, not papers)
- Blog posts without empirical claims
- Duplicate entries
- Entries where source credibility is not meaningful
