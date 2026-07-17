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
