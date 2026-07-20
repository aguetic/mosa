# Case 05: Mamari provenance

## Purpose

Test whether provenance accounts can be represented as structured, queryable event claims rather than leaving origins, destinations and participant roles embedded only in descriptive text.

## Phase 1 entities

- **Item:** one stable identity for the tablet
- **Names or designations:** Mamari; Text C
- **External identifier:** SSCC catalogue `P 003`
- **Classification:** rongorongo tablet
- **Agents:** Gaspar Zumbohm; Hippolyte Roussel; Tepano Jaussen; Congregation of the Sacred Hearts; Missionary Museum; French Navy as a reported participant in the 1892 account
- **Places:** Rapa Nui; Tahiti; Paris; Braine-le-Comte; Grottaferrata; Rome
- **Sources:** Paula Rossetti's note; the cited institutional records; the cited secondary and scholarly sources

Names and scholarly designations, external identifiers, and classifications must remain distinct in both the fixture and the explorer.

## Provenance pressure

The source packet contains more than one account of how Mamari left Rapa Nui and reached Tahiti. It also reports two incompatible accounts of a later deposit in Paris and a subsequent sequence of institutional relocations.

A generic participant role and a prose `described_as` value are not sufficient. The database must be able to answer, without parsing prose:

- which item moved;
- where it moved from and to;
- who is reported to have carried out the event;
- who or which institution is reported to have received the item;
- where the event occurred, separately from the recipient institution;
- when the event is reported to have occurred;
- which source supports each statement.

## Candidate events

These are research anchors, not accepted historical facts:

1. movement from Rapa Nui to Tahiti carried out by Roussel;
2. transfer to Jaussen according to the Roussel account;
3. departure or collection from Rapa Nui involving Zumbohm around 1870;
4. movement to Tahiti and transfer to Jaussen according to the Zumbohm account;
5. deposit in the Missionary Museum in Paris by Jaussen in 1888;
6. deposit in the Missionary Museum in Paris by the French Navy in 1892;
7. relocation to Braine-le-Comte in 1905;
8. relocation to Grottaferrata in 1953;
9. relocation to Rome in 1964.

The Roussel and Zumbohm chains remain separate. The two Paris accounts remain separate. Their possible incompatibility must be visible from their structured actor and date claims rather than through a claim-group table.

A 1974 move by the congregation is not modelled as a Mamari event unless evidence directly connects the tablet or its holding collection to that move.

## Required distinctions

- `moved_from` and `moved_to` must be independently queryable.
- `carried_out_by` and `transferred_to` must be independently queryable.
- For each Paris account, `occurred_at → Paris` and `transferred_to → Missionary Museum` must remain separate claims.
- The Paris deposit wording does not by itself justify `moved_to → Paris`; a physical movement destination is asserted only where the source supports it.
- Every provenance event must identify Mamari through `moved_item`.
- The Roussel and Zumbohm account chains must not share an event merely because both end in Tahiti or mention Jaussen.
- The Jaussen 1888 and French Navy 1892 Paris accounts must not be flattened into one event with cumulative participants and dates.
- `collected`, `removed`, `stolen`, `sold`, `sent`, and `deposited` remain source-attributed wording in `described_as` claims.
- Source excerpts must contain source wording or be null; internal event labels are not evidence excerpts.
- Later relocation claims do not imply ownership, lawful title, consent or authority.

## Questions

- Can SQL retrieve item, origin, movement destination, event location, actor, recipient, date and source without inspecting `described_as` text?
- Can separately attributed event accounts concern the same item without being merged?
- Can incompatible actor-and-date combinations remain independently queryable?
- Can the original wording remain visible without carrying the only structured meaning?
- Can later events be ordered while the earlier account chains remain unresolved?
- Can the explorer show the structured roles and evidence for each event?

## Pass condition

Mamari has one stable item identity. Nine event anchors represent two separate early account chains, two separate Paris accounts and three supported later relocations. The structured claims answer the competency questions without parsing descriptive prose. The Paris accounts distinguish the place of the deposit from the receiving institution. No event combines alternative actors or dates, and no unsupported 1974 object move, ownership, authority, consent or legal conclusion is introduced.

## Out of scope

- deciding which early or Paris account is historically correct;
- deciding whether separately modelled events describe the same real-world occurrence;
- a general participant-role table or complete provenance predicate vocabulary;
- explicit claim or conflict groups;
- resolving whether any transfer was lawful;
- restitution or return workflows;
- interpreting the rongorongo text.

## Implementation findings

- Provenance events work as stable research anchors when they share the existing entity identity space and are described through ordinary `knowledge.claim` rows.
- Important event details must be represented as structured claims rather than existing only in `described_as` text.
- The Mamari case established the need for the predicates `moved_item`, `moved_from`, `moved_to`, `occurred_at`, `carried_out_by`, and `transferred_to`.
- `occurred_at`, `moved_to`, and `transferred_to` answer different questions:
  - `occurred_at` identifies where an event happened;
  - `moved_to` identifies the geographical destination of a physical movement;
  - `transferred_to` identifies the person or organisation reported as receiving the item.
- The Missionary Museum and Paris must therefore be represented separately in the Paris deposit accounts.
- Competing accounts are best represented as separate event anchors when their combinations of actors, dates, or actions are incompatible.
- The Roussel and Zumbohm accounts must remain separate event chains rather than converging on one assumed Tahiti event.
- The Jaussen 1888 and French Navy 1892 Paris accounts must remain separate events rather than one event with cumulative participants and dates.
- Differences and possible incompatibilities between accounts can emerge from their structured claims and attribution. A separate claim-group or conflict-group model was not required.
- `described_as` remains useful for preserving original wording, uncertainty, and language, but it must not be the only place where queryable actors, places, recipients, or dates are recorded.
- Event details remain claims with their own status, asserting agent, notes, and evidence. Friendly explorer headings are projections of those claims, not canonical event fields.
- Evidence excerpts should contain source wording or be null. Internal entity labels and event labels must not be used as though they were quotations from a source.
- The reported 1974 move of the congregation must not be represented as a movement of Mamari unless evidence explicitly connects the tablet or its holding collection to that move.
- Movement and transfer claims do not imply ownership, legal title, consent, authority, or lawful acquisition.

## Result

Pass. A minimal provenance schema extension and new competency-derived predicates were required. The resulting model can represent the separate Mamari accounts and retrieve their item, origin, destination, event location, actor, recipient, date, attribution, and evidence without parsing descriptive prose.
