# Phase 2 provenance boundary

Status: defined for implementation and competency testing.

## Goal

Phase 2 adds a minimal provenance event model for representing what happened to an item, when, where, and involving whom, according to specific sources.

Events are stable research anchors. Their dates, participants, places, sequence, and characterisation remain sourced claims and may conflict.

## Included

- provenance events concerning Phase 1 items;
- event participation by agents;
- event places;
- uncertain or approximate event dates;
- ordering between events;
- competing descriptions of the same event;
- claim evidence and attribution using the Phase 1 knowledge model.

## Design gate

Before implementation, record how events become valid subjects and objects of claims. Phase 2 must extend the existing claim-and-evidence model rather than create a second, incompatible assertion system.

## Invariants

- An event is distinct from the item, agent, place, or source involved in it.
- Multiple sources may describe the same event differently.
- Terms such as `gift`, `removal`, `collection`, `sale`, or `theft` are attributed characterisations, not canonical event types unless the evidence supports that conclusion.
- Uncertain dates remain ranges or source wording; exact dates are not invented.
- Participants have explicit roles where the evidence permits them to be identified.
- Event order may be recorded without asserting unsupported exact dates.
- Missing participants, places, dates, or authority do not prevent an event from being represented.
- Provenance does not imply ownership, legality, consent, or lawful title.

## Competency cases

- Mamari: competing provenance sequences and several later institutional relocations.
- Te Papa moai kavakava: uncertain collection attribution and uncertain dates within one institutional account.
- Hoa Hakananaiʻa: a documented naval removal with competing characterisations.
- La Serena moai: a sparse 1952 transfer reported as a gift without clear authority or participants.

## Deferred

- restitution requests and case workflows;
- legal ownership or title determinations;
- consent and authority assessments;
- publication projections;
- import and reconciliation workflows;
- provenance completeness scores;
- automated timelines or route inference;
- a comprehensive event ontology.

New Phase 2 structures require a failing competency case or a recorded decision.
