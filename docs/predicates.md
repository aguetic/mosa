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
| `held_by`             | Agent   | An agent has physical custody or possession of an item; this does not imply ownership, title or lawful possession |
| `located_at`          | Place   | A source or agent states that an entity is at a place                                                             |
| `possibly_same_as`    | Entity  | Two entities may represent the same real-world thing, but the identity has not been resolved                      |
| `physical_remains_of` | Agent   | An item of physical human remains is associated with the person whose remains they are                            |
| `moved_item`          | Item    | The item reported as physically moved or transferred in an event                                                   |
| `moved_from`          | Place   | The reported origin of a movement                                                                                   |
| `moved_to`            | Place   | The reported geographical destination of a physical movement                                                                              |
| `carried_out_by`      | Agent   | The agent reported as actively carrying out an event                                                                |
| `transferred_to`      | Agent   | The reported person or organisation receiving an item in a transfer, without implying custody, title or ownership            |
| `occurred_at`         | Place   | A source or agent states where an event occurred; this is distinct from a movement destination                                                                    |
| `occurred_during`     | Literal | A source or agent gives an exact, approximate, ranged or alternative date description for an event                |
| `preceded_by`         | Event   | A source or agent places one event after another; this records partial ordering rather than a complete chronology |

## Phase 2 provenance conventions

- Provenance events are stable research anchors, not accepted historical conclusions.
- Use `provenance.event.event_kind` only for broad operational grouping. Preserve wording such as “collected”, “removed”, “stolen”, “gift”, “sent” or “deposited” in attributed `described_as` claims.
- Store event dates as structured literals so exact years, ranges and alternatives remain distinguishable.
- Use `preceded_by` only where a source supports the ordering. Multiple alternative predecessors may coexist.
- Event–item and participant relationships use competency-derived, role-bearing predicates. Phase 2 currently does not define generic event–item or participant predicates; later cases may introduce specific predicates they prove necessary.
- Use `moved_item`, `moved_from`, `moved_to`, `carried_out_by` and `transferred_to` only with the narrow meanings established by the Mamari case.
- Keep source wording in `described_as`, but do not leave an origin, destination, active agent or recipient only in prose when the source supports a structured claim.
- Distinguish event location from institutional recipient: for example, `occurred_at → Paris` and `transferred_to → Missionary Museum` answer different questions.
- An organisation may separately have a sourced `located_at` claim. Do not infer a historical event location from an organisation's current or undated location claim.
- Event details remain ordinary `knowledge.claim` rows. Explorer labels are projections of claims and should link back to claim identity, status, attribution and evidence.
- When several claims about one event are reported together, retain each atomic claim and attach its own evidence. Claims sharing an exact `source_id + locator + excerpt` tuple with a non-empty excerpt may be grouped in the explorer.
- Evidence-context grouping is a display convention, not a stable source-statement, account, evidence-unit or claim-group identity. Claims remain independently attributable and reviewable.
- Use one event anchor when the evidence explicitly presents alternative details for the same occurrence. Use separate provisional events when it is unresolved whether sources describe the same occurrence.
- Do not infer ownership, title, legality, authority or consent from a transfer or relocation event.

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
