# Phase 2 database boundary

Status: provisional provenance baseline for restitution integration, validated through Cases 05–09.

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
- `preceded_by` is not currently used to construct provenance chronology. Earlier fixtures that experimented with explicit event chains were revised to derive display order from structured dates instead. Events with equal or overlapping dates may remain only partially ordered.
- Relocation or transfer does not imply ownership, lawful title, consent or authority.
- Claims and claim evidence remain the only assertion mechanism.
- Event location, physical movement destination and recipient institution are distinct claim roles and are not inferred from one another.
- Formal event-identity resolution remains deferred.
- Display labels are presentation projections, not stored entity fields.

## Established provenance distinctions

### Production, findspot, movement and current state

- `made_at` records a reported production place.
- `found_at` records a reported findspot or documented early location.
- `moved_from` and `moved_to` record endpoints of a particular physical movement.
- `located_at` records a reported current or later location directly on the item when no provenance event is required.
- `held_by` records physical custody or possession directly on the item and does not imply ownership, lawful title or legitimate acquisition.
- A production place, findspot, movement origin and current location remain distinct roles even when two sources assign the same place to more than one role.

### Physical movement and transfer

- `moved_item` states that an event involved physical movement of an item.
- `transferred_item` states that an event involved a reported change of recipient, custody or institutional responsibility.
- A physical movement may exist without known endpoints or participants.
- A transfer may occur without a second physical movement.
- An event may contain both `moved_item` and `transferred_item` when the evidence supports physical movement and a custody or recipient change as part of the same episode.
- `transferred_to` records a reported recipient and does not establish ownership.
- `occurred_at`, `moved_to` and `transferred_to` must not be inferred from one another.
- Current custody is normally represented by direct item `held_by` and `located_at` claims rather than by inventing a continuing provenance event.

### Evidence scope

- `supports` is used when a source directly provides evidence for the specific claim being asserted.
- `provides_context` is used when a source is relevant to a claim but does not independently establish that exact object-level fact.
- Collection-level histories must not automatically become object-level `supports` evidence merely because an identified item belongs to the collection discussed.
- Broader wording such as the British Museum's description of Benin objects as official "spoils of war" may contextualise an object-level removal claim without being narrowed into a separate, directly supported claim about one object.
- Evidence notes and locators should make group-level, contextual or indirectly applied source scope visible.

## Competency ladder

Cases 05–09 establish a cumulative provenance competency ladder:

1. **Case 05 — structured movement and unresolved event identity**
   - represents movement origins, destinations, participants and recipients as queryable claims;
   - distinguishes event location from movement destination and recipient institution;
   - retains unresolved accounts as separate provisional event anchors.
2. **Case 06 — uncertainty within an institutional account**
   - preserves hypotheses without converting them into accepted facts;
   - represents source qualification without confidence scores or silent deletion;
   - preserves alternative dates as alternatives rather than selecting one or converting them into a continuous range.
3. **Case 07 — multiple perspectives and place-role distinctions**
   - attaches several attributed characterisations to one removal event;
   - distinguishes direct institutional and community evidence from indirectly reported community wording;
   - separates production place, findspot, movement origin, transport, transfer and current state;
   - distinguishes vessel, expedition and commander.
4. **Case 08 — sparse provenance**
   - represents a reported physical movement with year-level precision while leaving unsupported endpoints and participants absent;
   - preserves an indirect gift characterisation without inventing a giver, recipient, authority or community agent;
   - presents positive recorded information without filling the explorer with derived missing-value rows.
5. **Case 09 — military removal and evidence scope**
   - represents explicit military looting language without creating a canonical stolen status;
   - separates palace removal, government custody, temporary institutional loan and later gift;
   - distinguishes physical movement from transfer-only events;
   - distinguishes object-level support from broader collection-level context.

## Initial competency cases

- Case 05: Mamari provenance
- Case 06: Te Papa moai kavakava provenance
- Case 07: Hoa Hakananaiʻa provenance
- Case 08: La Serena moai provenance
- Case 09: Benin Ama provenance

The first vertical slice represents two unresolved early accounts, two separate provisional Paris deposit accounts, and a later sequence of institutional relocations while keeping one stable Mamari item identity. Each Paris account distinguishes `occurred_at → Paris` from `transferred_to → Missionary Museum`. The Mamari case introduces the predicates its competency questions require: `moved_item`, `moved_from`, `moved_to`, `carried_out_by` and `transferred_to`.

Case 06 extends Phase 2 by testing uncertainty within a single institutional provenance account. It does not introduce confidence scores or competing-claim groups. It tests whether hypotheses and qualifications can be represented through ordinary claims and evidence, and whether current custody can remain a direct item state.

Case 07 extends Phase 2 with one well-attested removal event that carries institutional, direct Rapa Nui and indirectly reported characterisations. It distinguishes `supports` evidence from a Ma’u Henua-authored source from `mentions` evidence in Paula Rossetti’s note. Transport remains a separate event using `moved_via`, while transfer events use `transferred_item`. The case distinguishes vessel, expedition and commander without a disagreement table, consent model or preferred narrative.

Case 07 also distinguishes production place, findspot, movement origin and current location. Source qualification of `made_at → Rano Kao` is represented through `qualifies` evidence rather than a qualification-specific predicate. Item pages project reported production and current recorded state ahead of findspot and the provenance-event sequence, with readable source labels and inline qualification wording.

Case 08 extends Phase 2 with a sparse provisional relocation: year-level `occurred_during`, `moved_item`, and an indirectly evidenced `described_as` gift characterisation with no asserting agent. It does not invent origin, destination, participants or a “Rapa Nui people” agent. Later museum custody remains a direct item state. Explorer presentation leads with positively recorded movement facts and source wording, using at most one incompleteness notice for unrecorded route and participants.

Case 09 tests a documented military removal followed by government custody, a possible temporary institutional loan and a later gift. Direct object-level claims remain distinct from collection-level contextual evidence. The case does not create a canonical stolen status or reintroduce explicit event-chain ordering.

## Known untested capability

`contradicts` is available for evidence that directly negates or materially conflicts with a specific claim, but no current competency fixture requires it.

Parallel attributed characterisations, alternative dates, unresolved event identities and statements that merely weaken or qualify a hypothesis must not be relabelled as contradiction solely to exercise the relationship.

A future contradiction case should be added only when one source directly supports a sufficiently precise claim and another source explicitly rejects or disproves that same claim. Until then, `contradicts` remains a documented but unproven capability of the Phase 2 model.

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
