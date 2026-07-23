# Derive entity display labels instead of storing working labels

## Status

Accepted

## Context

`working_label` was introduced on the base entity table as a non-authoritative operational convenience: a short string for humans and tooling when a proper name claim was not yet modeled or not needed.

In practice it became responsible for search, headings, links, sorting, fixture lookup, and event descriptions. That made it a cross-cutting dependency across schema, search, fixtures, read models, generated types, and UI.

Worse, it allowed missing structured claims to be concealed with unsourced prose. Events especially showed the failure mode: a convenient label became the de facto event model, compensating for incomplete claim structure rather than exposing it.

This decision is intentionally framed as **do not store generic entity display labels**, not merely “remove `working_label`.” The same rationale applies if someone later proposes `operational_label`, `display_name`, `title`, or another replacement field.

## Decision

- Remove `working_label` from the base entity table.
- Store names and designations only as attributed claims.
- Derive event titles from structured event claims.
- Derive other entity display labels from name claims, identifiers, or source references.
- Use explicit UUID-based fallbacks when no displayable assertion exists.
- Do not use notes, descriptive claims, or evidence excerpts as silent label fallbacks.
- Do not introduce a replacement generic label column.

Display labels are presentation projections. They are not preferred names, entity identity, or historical assertions.

## Consequences

### Positive

- Modeling gaps remain visible instead of being papered over with prose.
- Unsourced text cannot become canonical by accident.
- UI language remains reproducible from structured data.
- Competency cases exercise the actual model rather than a parallel label layer.
- Names retain attribution, evidence, language, and status.

### Costs

- Search and read models become more complex.
- Unnamed entities need visibly generic fallbacks.
- Choosing among several name claims requires a deterministic presentation policy.
- Event titles may change as claims change.
- Fixtures must use IDs rather than labels for references.

These costs are accepted because the alternative—keeping a stored escape hatch—is cheaper only until more fixtures, UI, and search depend on it, after which reversing the decision is expensive.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep `working_label` but document its limited role | Documentation does not stop convenience from becoming canonical. |
| Rename it to `operational_label` | Same escape hatch under a different name. |
| Make it nullable | Still invites unsourced prose wherever a label is “needed.” |
| Store generated event titles | Reifies a disposable projection as entity data; titles drift from claims. |
| Use notes or `described_as` as display fallbacks | Informative but unsourced text becomes a silent label. |

The common failure: each option preserves a path where convenient prose compensates for missing structure.

## Guardrails

1. **A generic fallback is preferable to an informative but unsourced label.**
2. **Display projections are disposable** and must not be treated as entity identity or historical assertions.
3. **A proposal for a new stored label field requires a new ADR.**

Implementation (migrations, read models, fixtures, UI) should refer to this ADR. Acceptance criteria should verify that the architectural decision — not merely the current refactor — has been implemented.
