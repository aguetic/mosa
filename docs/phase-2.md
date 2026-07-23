# Phase 2 database boundary

Status: active vertical slice, validated through provenance competency cases.

## Goal

Represent competing, incomplete and temporally ordered accounts of how an item moved between people, places and institutions without turning one account into canonical truth.

## Included

### Provenance events

- stable event identities;
- broad operational event kinds;
- events as subjects and objects of ordinary claims;
- event items, movement origins and destinations, event locations, active agents, recipient institutions, dates and descriptions expressed through attributed claims;
- claim-level source evidence;
- read-only exploration of an item's events;
- event display order derived from structured date claims;
- event titles generated from structured claims as presentation projections;
- unresolved accounts retained as separate provisional event anchors;
- current states such as custody that may remain direct item claims rather than provenance events.

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
- Separate provisional event anchors are used when event identity is unresolved.
- Historical and legal wording remains source-attributed; descriptive prose is not the only storage location for queryable event details.
- Event dates may be exact, approximate, ranged or alternative and must not be normalised beyond the evidence.
- Display order is derived from structured date claims and does not assert a complete or continuous historical chronology.
- Relocation or transfer does not imply ownership, lawful title, consent or authority.
- Claims and claim evidence remain the only assertion mechanism.
- Event location, physical movement destination and recipient institution are distinct claim roles and are not inferred from one another.
- Formal event-identity resolution remains deferred.
- Display labels are presentation projections, not stored entity fields.

## Initial competency cases

- Case 05: Mamari provenance
- Case 06: Te Papa moai kavakava provenance
- Case 07: Hoa Hakananaiʻa provenance

The first vertical slice represents two unresolved early accounts, two separate provisional Paris deposit accounts, and a later sequence of institutional relocations while keeping one stable Mamari item identity. Each Paris account distinguishes `occurred_at → Paris` from `transferred_to → Missionary Museum`. The Mamari case introduces the predicates its competency questions require: `moved_item`, `moved_from`, `moved_to`, `carried_out_by` and `transferred_to`.

Case 06 extends Phase 2 by testing uncertainty within a single institutional provenance account. It does not introduce confidence scores or competing-claim groups. It tests whether hypotheses and qualifications can be represented through ordinary claims and evidence, and whether current custody can remain a direct item state.

Case 07 extends Phase 2 with one well-attested removal event that carries institutional, direct Rapa Nui and indirectly reported characterisations. It distinguishes `supports` evidence from a Ma’u Henua-authored source from `mentions` evidence in Paula Rossetti’s note. Transport remains a separate event using `moved_via`, while transfer events use `transferred_item`. The case distinguishes vessel, expedition and commander without a disagreement table, consent model or preferred narrative.

## Deferred

- a complete provenance ontology;
- fixed participant-role tables;
- automated chronology reconciliation;
- ownership and legal-title conclusions;
- consent and authority determinations;
- restitution workflows;
- provenance editing interfaces;
- general-purpose ingestion;
- stable source-statement, evidence-unit, claim-group or conflict-group identities;
- formal event-identity resolution.

New Phase 2 structures require a failing provenance competency test or a recorded decision.
