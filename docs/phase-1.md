# Phase 1 database boundary

Status: frozen for implementation and regression testing.

## Included

### Entities

- `item`
- `agent`
- `place`
- `source`

### Canonical storage

- `entities.entity`
- `entities.item`
- `entities.agent`
- `entities.place`
- `entities.source`
- `entities.external_identifier`
- `knowledge.claim`
- `knowledge.claim_evidence`

### Database API

- `knowledge.claim_details`
- `knowledge.claim_evidence_details`
- `entities.create_item(...)`
- `entities.create_agent(...)`
- `entities.create_place(...)`
- `entities.create_source(...)`

## Invariants

- Sources remain distinct from the entities they describe.
- Claims have exactly one entity or literal value.
- Conflicting claims may coexist.
- Evidence links a claim to a source.
- Possible identity is represented as a reversible claim, not a merge.
- An ancestral person is an agent; physical remains are an item.
- Custody does not imply ownership.

## Deferred

- provenance events;
- restitution workflows;
- publication projections;
- ingestion and staging;
- review workflows;
- automated identity resolution;
- sensitivity and access governance.

New Phase 1 structures require a failing competency test or a recorded decision.