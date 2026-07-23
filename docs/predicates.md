# Predicates

| Predicate             | Value   | Meaning                                                                                                           |
| --------------------- | ------- | ----------------------------------------------------------------------------------------------------------------- |
| `refers_to`           | Entity  | A non-visual source or record refers to an entity                                                                 |
| `depicts`             | Entity  | A visual or audiovisual source visibly represents an entity                                                       |
| `authored_by`         | Agent   | An agent is responsible for the intellectual content of a source                                                  |
| `published_by`        | Agent   | An agent issued or made a source publicly available                                                               |
| `has_name`            | Literal | A source or agent uses a name for an entity                                                                       |
| `classified_as`       | Literal | A source or agent assigns a classification                                                                        |
| `described_as`        | Literal | A source or agent provides a descriptive interpretation of an entity                                              |
| `made_of`             | Literal | A source or agent identifies a material                                                                           |
| `made_at`             | Place   | The reported place where an item was made                                                                         |
| `made_during`         | Literal | The reported production date or period, represented as a structured date literal                                  |
| `found_at`            | Place   | The reported findspot or documented discovery location of an item                                                 |
| `held_by`             | Agent   | An agent has physical custody or possession of an item; this does not imply ownership, title or lawful possession |
| `located_at`          | Place   | A source or agent states that an entity is at a place                                                             |
| `possibly_same_as`    | Entity  | Two entities may represent the same real-world thing, but the identity has not been resolved                      |
| `physical_remains_of` | Agent   | An item of physical human remains is associated with the person whose remains they are                            |
| `moved_item`          | Item    | The item reported as physically moved in an event                                                                   |
| `moved_from`          | Place   | The reported origin of a movement                                                                                   |
| `moved_to`            | Place   | The reported geographical destination of a physical movement                                                                              |
| `moved_via`           | Item    | The vessel or transport medium reportedly used for a physical movement                                              |
| `carried_out_by`      | Agent   | The agent reported as actively carrying out an event                                                                |
| `commanded_by`        | Agent   | A vessel is reported as having been commanded by a person                                                           |
| `transferred_item`    | Item    | The item concerned by a reported institutional or interpersonal transfer; does not by itself assert physical movement, ownership, legal title, authority or consent |
| `transferred_to`      | Agent   | The reported person or organisation receiving an item in a transfer, without implying custody, title or ownership            |
| `held_item`           | Item    | Identifies the item involved in a holding episode |
| `holding_agent`       | Agent   | Identifies the reported holder in a holding episode |
| `transferred_from`    | Agent   | Identifies the reported source party in a transfer |
| `occurred_at`         | Place   | A source or agent states where an event occurred; this is distinct from a movement destination                                                                    |
| `occurred_during`     | Literal | A source or agent gives an exact, approximate, ranged or alternative date description for an event                |

## Phase 2 provenance conventions

- Provenance events are stable research anchors, not accepted historical conclusions.
- Use `provenance.event.event_kind` only for broad operational grouping. Preserve wording such as “collected”, “removed”, “stolen”, “gift”, “sent” or “deposited” in attributed `described_as` claims.
- Store event dates as structured literals so exact years, ranges and alternatives remain distinguishable.
- Provenance events are displayed using their structured date claims. Display ordering is a presentation projection and does not assert a complete or continuous historical chronology.
- Event titles are presentation projections generated from structured claims.
- Display labels for entities are presentation projections derived from attributed `has_name` claims, external identifiers, source references, or event summaries. The former stored `working_label` and `notes` columns on entities have been removed; see ADR 010.
- Event–item and participant relationships use competency-derived, role-bearing predicates. Phase 2 currently does not define generic event–item or participant predicates; later cases may introduce specific predicates they prove necessary.
- Use `moved_item`, `moved_from`, `moved_to`, `moved_via`, `carried_out_by`, `transferred_item`, `transferred_from` and `transferred_to` only with the narrow meanings established by the provenance cases.
- `transferred_item` identifies the item concerned by a transfer. It does not by itself assert physical movement. Use `moved_item` separately when physical movement is also supported. The two predicates are not mutually exclusive.
- Use `moved_via` for the reported vessel or transport medium. Do not use `carried_out_by` on a vessel; vessels are items, not acting agents.
- `commanded_by` is currently a vessel-to-person relationship (`HMS Topaze commanded_by Richard Ashmore Powell`). It does not make the commander a direct participant in every event involving that vessel.
- Item provenance discovery inspects `moved_item`, `held_item` and `transferred_item`.
- `held_item` identifies the item involved in a holding episode; `holding_agent` identifies the reported holder in that episode.
- `held_by` remains a direct current or undated custody claim on an item. Do not create a provenance event merely because an item has a current holder or current location.
- Keep source wording in `described_as`, but do not leave an origin, destination, active agent or recipient only in prose when the source supports a structured claim.
- `made_at`, `found_at`, `moved_from` and `located_at` answer different questions. Do not infer any one from another.
- A reported production place remains an ordinary `made_at` claim even when a source qualifies it as possible, probable or likely.
- Represent source qualification through a `qualifies` evidence relationship and preserve the source wording in the evidence excerpt.
- Do not create predicate variants such as `possibly_made_at`, `probably_made_at` or `likely_made_at`.
- `made_during` uses the same structured date-literal conventions as `occurred_during`, including precision, approximation, ranges and alternatives.
- Item pages may project production and current-state claims prominently, but those projections remain disposable presentation views over attributed claims.
- Item-page projections may surface `qualifies` wording beside a claim value so the first reading does not sound more certain than the evidence.
- Distinct `located_at` claims may use presentation labels such as broader location and display location; the underlying predicate remains `located_at`.
- Distinguish event location from institutional recipient: for example, `occurred_at → Paris` and `transferred_to → Missionary Museum` answer different questions.
- Do not infer collection events from arrival events. Arrival in a country, city, or institution does not establish where or when an object was collected.
- Preserve institutional uncertainty through claim evidence relationships such as `qualifies`; do not convert uncertainty into confidence scores.
- An organisation may separately have a sourced `located_at` claim. Do not infer a historical event location from an organisation's current or undated location claim.
- Event details remain ordinary `knowledge.claim` rows. Explorer labels are projections of claims and should link back to claim identity, status, attribution and evidence.
- Create one provisional event anchor for each source-reported account or explicitly paired alternative account. Merge event anchors only when the project is sufficiently confident that the claims describe one occurrence.
- Unresolved accounts remain separate provisional events. Do not infer that two provisional events represent the same historical occurrence.
- Do not infer ownership, title, legality, authority or consent from a transfer or relocation event.
- Do not create placeholder agents for unidentified participants. Absence of a role claim is the representation of an unrecorded detail.
- When a source reports a characterisation without identifying the underlying speaker, leave `asserted_by_agent_id` null and attach the source with `mentions`.
- Prefer `moved_item` with `event_kind = relocation` when physical movement is the supported claim and a transfer or gift interpretation remains uncertain. Do not add `transferred_item` merely to aid discovery.
- Later presence at an institution or place does not by itself establish `moved_to`, `transferred_to` or `occurred_at` for an earlier provisional event.
- Explorer projections may omit absent origin, destination or participant roles on overview cards. Event detail pages may show one compact incompleteness notice when that prevents misunderstanding. “Not recorded” wording is presentation only and must not be stored as a claim value.
- Sparse movement presentations should state that a source reports movement, surface source characterisation wording, and use at most one incompleteness notice for unrecorded route or participants.

## Evidence relationships

| Relationship       | Meaning                                                                     |
| ------------------ | --------------------------------------------------------------------------- |
| `supports`         | The source directly provides evidence for the claim                         |
| `mentions`         | The source reports, quotes or refers to the assertion indirectly            |
| `contradicts`      | The source provides evidence against the claim                              |
| `qualifies`        | The source narrows, modifies or adds conditions to the claim                |
| `provides_context` | The source is relevant to the claim but does not independently establish it |

## Conventions

- Attribute project interpretations and identity hypotheses to the specific team member who made them.
- Leave `asserted_by_agent_id` null only when the asserting person or organisation is genuinely unknown or has not yet been recorded.
- Preserve source-language wording in literal claims.
- Record translations or normalised wording as separate claims attributed to the person or source responsible.
- Store a symmetric claim such as `possibly_same_as` once; queries should inspect both its subject and object.
