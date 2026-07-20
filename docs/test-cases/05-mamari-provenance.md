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

The source packet contains more than one account of how Mamari left Rapa Nui and reached Tahiti. It also reports one later deposit in Paris through two alternative actor-and-date reconstructions, followed by a sequence of institutional relocations.

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
5. deposit in the Missionary Museum in Paris, reported as either carried out by Jaussen in 1888 or by the French Navy in 1892;
6. relocation to Braine-le-Comte in 1905;
7. relocation to Grottaferrata in 1953;
8. relocation to Rome in 1964.

The Roussel and Zumbohm chains remain separate because the available material does not establish that their event anchors describe the same occurrences. The Paris alternatives instead describe one deposit event. Their actor-and-date pairings are preserved by the exact existing evidence contexts attached to the claims, without a claim-group or source-statement identity.

A 1974 move by the congregation is not modelled as a Mamari event unless evidence directly connects the tablet or its holding collection to that move.

## Required distinctions

- `moved_from` and `moved_to` must be independently queryable.
- `carried_out_by` and `transferred_to` must be independently queryable.
- The single Paris event must contain one `moved_item → Mamari`, one `occurred_at → Paris`, and one `transferred_to → Missionary Museum` claim.
- The Paris deposit wording does not by itself justify `moved_to → Paris`; a physical movement destination is asserted only where the source supports it.
- Every provenance event must identify Mamari through `moved_item`.
- The Roussel and Zumbohm account chains must not share an event merely because both end in Tahiti or mention Jaussen.
- The Jaussen and 1888 claims must share one identical `source_id + locator + excerpt` evidence context.
- The French Navy and 1892 claims must share a different identical evidence context, preventing unintended Jaussen–1892 or French Navy–1888 combinations in presentation.
- Matching evidence contexts are a lightweight presentation convention, not stable account identities or formal claim groups.
- `collected`, `removed`, `stolen`, `sold`, `sent`, and `deposited` remain source-attributed wording in `described_as` claims.
- Source excerpts must contain source wording or be null; internal event labels are not evidence excerpts.
- Later relocation claims do not imply ownership, lawful title, consent or authority.

## Questions

- Can SQL retrieve item, origin, movement destination, event location, actor, recipient, date and source without inspecting `described_as` text?
- Can uncertain event identity remain separate from uncertainty about an otherwise shared event?
- Can the alternative Jaussen–1888 and French Navy–1892 pairs remain independently queryable on one event?
- Can the explorer group correlated claims by existing evidence context without introducing a new ontology entity?
- Can the original wording remain visible without carrying the only structured meaning?
- Can later events be ordered while the earlier account chains remain unresolved?
- Can the explorer show the structured roles and evidence for each event?

## Pass condition

Mamari has one stable item identity. Eight event anchors represent two separate early account chains, one Paris deposit event and three supported later relocations. The Paris event stores its shared item, location and recipient once while retaining two correlated actor-and-date alternatives through existing claim evidence. The structured claims answer the competency questions without parsing descriptive prose, and no unsupported 1974 object move, ownership, authority, consent or legal conclusion is introduced.

## Out of scope

- deciding which early or Paris account is historically correct;
- deciding whether the separately modelled early events describe the same real-world occurrences;
- a general participant-role table or complete provenance predicate vocabulary;
- formal source statements, evidence-unit identities, or explicit claim and conflict groups;
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
- The Missionary Museum and Paris must therefore be represented as separate claims on the Paris deposit event.
- Conflicting properties do not necessarily imply distinct events. When a source explicitly frames actor-and-date combinations as alternatives for one occurrence, one event anchor is more accurate.
- The Roussel and Zumbohm accounts must remain separate event chains rather than converging on one assumed Tahiti event.
- The Jaussen–1888 and French Navy–1892 pairings can be preserved by giving each pair the same exact `source_id`, `locator`, and `excerpt` values in existing claim evidence.
- The explorer may group claims that share an exact evidence context under the generic label “Reported together”. This grouping is a derived presentation and has no formal identity; it does not infer semantic alternatives from English wording.
- Claims with unique or incomplete evidence contexts remain visible as ordinary statements.
- Exact-tuple grouping is intentionally provisional and presentational. A formal source-statement, evidence-unit, claim-group, or conflict-group model may be introduced only when another case proves it necessary.
- Event identity must be decided separately from uncertainty about properties claimed of an event.
- `described_as` remains useful for preserving original wording, uncertainty, and language, but it must not be the only place where queryable actors, places, recipients, or dates are recorded.
- Event details remain claims with their own status, asserting agent, notes, and evidence. Friendly explorer headings are projections of those claims, not canonical event fields.
- Evidence excerpts should contain source wording or be null. Internal entity labels and event labels must not be used as though they were quotations from a source.
- The reported 1974 move of the congregation must not be represented as a movement of Mamari unless evidence explicitly connects the tablet or its holding collection to that move.
- Movement and transfer claims do not imply ownership, legal title, consent, authority, or lawful acquisition.

## Result

Pass. No additional schema structure was required for correlated alternatives. The model represents the Paris deposit once, preserves its two actor-and-date pairings through existing claim evidence, and keeps the grouping explicitly provisional and presentational.
