# Do not store generic descriptive prose on entities

## Status

Accepted

## Context

The base entity table originally included `working_label` as a non-authoritative operational convenience.

In practice, it became responsible for search, headings, links, sorting, fixture lookup, and event descriptions. `entities.entity.notes` developed a similar role: fixture and event prose appeared in the explorer and was sometimes queried by tests to determine whether historical meaning had been modeled.

Both fields created a parallel, unsourced description layer. They allowed incomplete structured claims to be concealed by convenient prose, particularly for provenance events.

This decision applies to any proposed replacement such as `operational_label`, `display_name`, `title`, `summary`, or a general-purpose entity-description field.

## Decision

Entity rows will store identity and subtype structure, not generic descriptive prose.

Therefore:

- remove `working_label` from `entities.entity`;
- remove `notes` from `entities.entity`;
- do not introduce replacement generic label or description columns;
- represent names, descriptions, classifications, relationships, and historical information through attributed claims;
- derive event titles from structured event claims;
- derive other display labels from name claims, identifiers, source references, or explicit generic UUID-based fallbacks;
- do not derive labels or summaries from notes, evidence excerpts, or descriptive prose used as a silent fallback.

Display labels and summaries are presentation projections. They are not entity identity, preferred names, or historical assertions.

`knowledge.claim.notes` and `knowledge.claim_evidence.notes` remain available as editorial metadata. They may document encoding decisions, transcription issues, data-quality concerns, or evidence-locator limitations, but must not supply domain meaning.

## Consequences

### Benefits

- Modeling gaps remain visible.
- Unsourced prose cannot become canonical accidentally.
- User-facing descriptions remain reproducible from structured data.
- Competency cases test the actual claim model.
- Names retain attribution, evidence, language, and status.

### Costs

- Search and read projections become more complex.
- Unnamed entities require generic fallbacks.
- Choosing among multiple name claims requires deterministic presentation rules.
- Generated event titles may change when their claims change.
- Fixtures must reference entities by stable identifiers rather than labels.

These costs are accepted because retaining generic prose fields would allow more schema, UI, and fixture behavior to depend on an unsourced escape hatch.

## Alternatives considered

| Alternative                                                          | Reason rejected                                                                       |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Retain `working_label` with stricter documentation                   | Convenience fields had already become semantically significant despite documentation. |
| Rename it to `operational_label`                                     | Preserves the same escape hatch under a different name.                               |
| Make labels or notes nullable                                        | Still encourages prose whenever structured data is inconvenient.                      |
| Store generated event titles                                         | Turns a disposable projection into canonical entity data.                             |
| Use notes, `described_as`, or evidence excerpts as display fallbacks | Allows unsourced or context-specific prose to silently define entity meaning.         |
| Automatically convert existing prose into claims                     | Would create assertions without establishing attribution or evidence.                 |

## Principle

> Entity rows store identity and subtype structure. Domain meaning is represented through attributed claims. User-facing descriptions are derived projections. Generic prose must not compensate for missing structure.
