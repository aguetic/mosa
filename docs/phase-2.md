# Phase 2 database boundary

Status: active vertical slice, validated through provenance competency cases.

## Goal

Represent competing, incomplete and temporally ordered accounts of how an item moved between people, places and institutions without turning one account into canonical truth.

## Included

### Provenance events

- stable event identities;
- broad operational event kinds;
- events as subjects and objects of ordinary claims;
- event items, movement origins and destinations, event locations, active agents, recipient institutions, dates, descriptions and ordering expressed through attributed claims;
- claim-level source evidence;
- read-only exploration of an item's event sequence.

### Canonical storage

- `provenance.event`
- the Phase 1 entity, claim and evidence tables

An event is also an `entities.entity` row with `entity_type = 'event'`. Phase 2 does not introduce separate provenance claim or provenance evidence tables.

### Initial database API

- `provenance.create_event(...)`
- the existing `knowledge.claim_details`
- the existing `knowledge.claim_evidence_details`

## Invariants

- Events are research anchors, not accepted historical facts.
- Competing event accounts may coexist as separate event anchors whose structured details can be compared.
- Historical and legal wording remains source-attributed; descriptive prose is not the only storage location for queryable event details.
- Event dates may be exact, approximate, ranged or alternative and must not be normalised beyond the evidence.
- Event ordering is partial and sourced; missing links are not inferred.
- Relocation or transfer does not imply ownership, lawful title, consent or authority.
- Claims and claim evidence remain the only assertion mechanism.
- Event location, physical movement destination and recipient institution are distinct claim roles and are not inferred from one another.

## Initial competency case

- Case 05: Mamari provenance

The first vertical slice must represent two unresolved early account chains, two incompatible Paris deposit accounts and a later sequence of institutional relocations while keeping one stable Mamari item identity. The Paris accounts distinguish `occurred_at → Paris` from `transferred_to → Missionary Museum`. The Mamari case introduces only the predicates its competency questions require: `moved_item`, `moved_from`, `moved_to`, `carried_out_by` and `transferred_to`.

## Deferred

- a complete provenance ontology;
- fixed participant-role tables;
- automated chronology reconciliation;
- ownership and legal-title conclusions;
- consent and authority determinations;
- restitution workflows;
- provenance editing interfaces;
- general-purpose ingestion.

New Phase 2 structures require a failing provenance competency test or a recorded decision.
