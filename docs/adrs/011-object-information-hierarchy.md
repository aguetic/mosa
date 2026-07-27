# Present object information in a fixed priority order

## Status

Accepted

## Context

Cultural heritage objects are the primary research unit in MoSA. Readers asking about an object almost always need the same facts first: where it is from, where it is now, what documents describe it, and how it got there. Everything else — names, materials, classifications, restitution administration — matters, but later.

The claim and provenance model already distinguishes these roles (`made_at`, `found_at`, `held_by`, `located_at`, sources, provenance events). The Explorer item page did not. Production and custody appeared before provenance, but documents were buried in per-claim evidence and generic incoming claims, findspot was optional, provenance had no empty state, and record metadata competed for attention at the top of the page.

Without an explicit hierarchy, fixtures, competency questions, and future projections will keep optimising for schema completeness rather than object-centred reading.

## Decision

Object-facing projections — starting with the Explorer item page — present information in this order:

1. **Origin** — where the object is from (`made_at`, `made_during`, `found_at`), kept distinct as predicates but grouped as one answer.
2. **Current location** — where it is now (`held_by`, `located_at`). Custody does not imply ownership.
3. **Documents** — sources that describe, depict, evidence, or administratively document the object.
4. **Provenance** — how it got there (`provenance.event` and related claims).
5. **Everything else** — remaining claims, restitution case summaries, identifiers, and record metadata.

Therefore:

- do not invent schema columns for “origin”, “documents”, or similar rollups;
- derive the hierarchy as a presentation projection from existing claims, sources, evidence, provenance events, and restitution document links;
- always surface tiers 1–4 for items, including empty states when nothing is recorded;
- keep restitution cases below provenance; surface restitution *documents* under documents;
- keep predicate distinctions (production ≠ findspot ≠ movement origin ≠ current location).

## Consequences

### Benefits

- Item pages answer the first questions readers ask.
- Missing origin, location, documents, or provenance stays visible.
- Fixtures and competency packets can check tier coverage without new tables.
- Shared projection code can stay aligned across Explorer and later APIs.

### Costs

- Item pages become more projection-heavy.
- Document aggregation must deduplicate sources that appear as both evidence and direct links.
- Sparse objects will show several empty sections.

These costs are accepted: empty tiers are more honest than a page that looks complete because undocumented sections are hidden.

## Alternatives considered

| Alternative | Reason rejected |
| --- | --- |
| Add origin/location/document columns on `entities.item` | Duplicates attributed claims and hides source disagreement. |
| Keep documents only as claim evidence | Forces readers to discover sources by scanning every claim. |
| Treat restitution as tier 4 alongside provenance | Restitution is operational case management; movement history remains provenance. |
| Hide empty tiers | Conceals what the research record does not yet know. |

## Principle

> For objects, present origin, current location, documents, and provenance before everything else. The hierarchy is a projection, not a schema change.
