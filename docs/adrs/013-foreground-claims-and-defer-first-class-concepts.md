# Foreground selected claims and defer first-class Concepts

## Status

Accepted

## Context

MoSA represents knowledge about collection items as attributed claims with
evidence. Different names, classifications and descriptions can coexist without
being collapsed into a single canonical account or stored as intrinsic
properties of an item.

This claim-first structure preserves plurality, but plurality does not determine
presentation. A plural record does not choose its own starting point. MoSA must
still decide which attributed perspective first introduces an item, which
relationships receive immediate attention and how readers are oriented to the
record.

That decision is part of MoSA's editorial authorship. MoSA is a situated,
collaborative and reparative project rather than a neutral view from nowhere. It
may therefore give selected claims greater editorial salience where doing so
serves the purpose and methodology of the project.

Foregrounding does not make the selected claim intrinsic to the item. It does
not declare the claim universally true, evidentially superior in every context,
or representative of an entire people or community. The claim remains the
statement of particular, identified speakers, supported by particular evidence
and open to disagreement and revision. Other claims remain available with their
own attribution and evidence.

The required position is therefore **attributed plurality with accountable
foregrounding**:

- use the same claim architecture to preserve different accounts;
- retain the identity, position, wording and evidence of each account;
- allow MoSA to select particular claims as the first description of an item;
- treat that selection as an editorial act rather than a truth ranking;
- keep the selection explicit and reversible.

Discussion of foregrounding raised a related proposal: represent terms such as
*moai*, *moai kavakava*, *ivi tupuna*, *ta‘oa*, *mana* and sacred geography as
first-class Concept entities. A Concept could distinguish general knowledge
about an object type or cultural category from knowledge about a particular
item. It could also provide a reusable subject for definitions, terminology
variants and relationships.

Those capabilities may become useful, but they are not necessary merely to
foreground an attributed claim. Introducing Concepts would create additional
curatorial responsibilities: deciding when two uses denote the same Concept,
maintaining definitions and mappings, deciding when Concepts should be split or
merged, and avoiding the presentation of situated knowledge as a single stable
ontology. The candidate terms also do not all behave as object types; they
include classifications, qualities, relationships, statuses and interpretations
of place.

This decision therefore addresses two questions:

1. How should MoSA record an editorial choice to foreground a claim?
2. What demonstrated requirements would justify first-class Concepts later?

## Relevant principles

### Preserve attributed plurality

Every claim retains its speaker, wording, evidence, status and history.
Foregrounding one claim does not remove, rewrite, invalidate or reduce the
visibility of another claim.

Plurality does not require MoSA to treat claims as interchangeable or to give
them identical editorial prominence. Structural consistency in the database and
editorial salience in a presentation are different concerns.

### Accept responsibility for editorial salience

The first description of an item frames how readers encounter the rest of the
record. Selecting it is an editorial and political act, even when every
underlying claim remains available.

MoSA records that choice explicitly rather than presenting order and emphasis as
the neutral output of the data model. The selection expresses MoSA's situated
purpose and does not become a universal property of the selected claim.

### Distinguish editorial, epistemic and ontological priority

Foregrounding gives a claim editorial salience within MoSA. It does not give the
claim a database-wide credibility score, make it an ontological essence, or
establish that the speaker has authority in every domain.

Epistemic assessment remains claim-specific and topic-specific. A person's
social position and relationship to an item or cultural practice may provide
knowledge unavailable from another position, but identity alone does not make
every statement infallible. Attribution and evidence remain necessary.

### Support agency rather than presence alone

It is possible to include many voices while giving none of them meaningful
influence over how a record is interpreted. MoSA's collaborative methodology
requires more than accepting additional statements as data. It must be possible
for knowledge arising through the collaboration to shape the reader's first
encounter with an item.

This does not turn an individual collaborator into the voice of a whole
community. Each claim remains situated and specifically attributed.

### Separate knowledge from presentation

A domain claim records what an identified agent asserted and what evidence
supports it. Foregrounding records what MoSA chooses to emphasise. These are
different kinds of information and must not be stored in the same field.

### Keep the database modest

MoSA records knowledge about items and supports provenance, restitution and
repair work. It does not attempt to recreate or exhaustively formalise a Rapa
Nui knowledge system. New ontology structures require demonstrated research or
user-facing behaviour, not only conceptual plausibility.

### Prefer reversible, competency-driven extensions

The smallest structure that satisfies a current competency should be preferred.
Additional context, ordering, decision provenance, governance history or
ontology structure can be added through later migrations when real cases
require them.

### Do not infer treatment from classification

A classification may inform ethical consideration, but it does not by itself
establish a care protocol, access restriction, legal conclusion or restitution
outcome. Those must remain separately attributed decisions or claims.

## Options considered

### Preserve claims without recording foregrounding

The Explorer could display all relevant claims without recording which claim
MoSA has deliberately selected as the first description.

This option was rejected because it represents plurality but not the project's
editorial decision. It would make foregrounding unavailable as an explicit,
queryable part of the presentation model.

### Derive foregrounding from predicates, speakers or literal values

Application code could prefer particular predicates, named agents or values
such as `moai`.

This option was rejected because foregrounding is a decision about a particular
claim in a particular record. A general rule about a term or speaker would hide
that choice in application logic, imply broader authority than intended and
make exceptions difficult to explain.

### Mark a claim or Concept as globally primary

A column such as `is_primary`, `priority` or `authority` could be added to a
claim or Concept.

This option was rejected because editorial salience is not intrinsic to a claim
or Concept. A global flag would conflate MoSA's presentation decision with
epistemic authority or ontological priority.

### Introduce first-class Concepts now

MoSA could add a Concept entity type, describe each Concept through claims and
link item classifications to Concept entities rather than literals.

This would support reusable definitions, Concept pages, cross-item queries,
terminology mapping and structured Concept relationships. It would also require
MoSA to curate Concept identity and scope before any current competency has
shown that a literal classification, its evidence and its sources are
insufficient.

This option was deferred rather than rejected. Foregrounding does not depend on
it, and literal claims remain valid evidence if Concepts are introduced later.

### Record foregrounding in a minimal presentation relation

A separate table can identify the claims that MoSA selects for foregrounding in
its default presentation. The presence of a claim identifier in that table is
the whole selection.

This option was selected because it makes the editorial decision explicit while
leaving the meaning, attribution and evidential status of the claim unchanged.
It meets the current requirement without introducing speculative ontology,
workflow or ranking structures.

## Decision

Create `presentation.foregrounded_claim` with one column:

```sql
create schema if not exists presentation;

create table presentation.foregrounded_claim (
    claim_id uuid primary key
        references knowledge.claim(id)
        on delete cascade
);
```

A row means:

> MoSA selects this claim for foregrounding in its default presentation.

The selected claim may provide the first description of an item or otherwise
receive prominent placement appropriate to the presentation. The selection is
MoSA's editorial act. It is not part of what the original speaker asserted.

The following constraints apply:

- the selected claim remains an ordinary `knowledge.claim`;
- its attribution, evidence, literal wording, status and supersession determine
  what the claim says and who said it;
- competing claims remain available and visible;
- more than one claim about an entity may be foregrounded;
- presentation queries return only foregrounded claims whose claim status is
  `active`;
- deleting a claim deletes its dependent foregrounding row;
- foregrounding is selected claim by claim, not inferred from an agent,
  institution, community, predicate or literal value;
- no context, role, position, rationale, status or audit columns are added until
  a demonstrated workflow requires them.

The initial table represents one default MoSA presentation. If distinct
presentation contexts later require different selections, a later migration may
add a context key and replace the primary key with a composite key. Ordering,
decision provenance and foregrounding history are likewise deferred until they
are required.

MoSA will not add first-class Concepts as part of this decision.

## Competency decisions for foregrounding

The implementation must demonstrate that:

1. An attributed classification or description can be foregrounded without
   modifying the underlying claim.
2. The foregrounded claim retains visible attribution and evidence.
3. Other claims about the item remain intact, queryable and visible.
4. Several claims about one item can be foregrounded without creating an
   implicit truth ranking among them.
5. The same claim cannot be selected twice.
6. A withdrawn or superseded claim is not returned by the active foregrounding
   projection, even if its selection row remains present.
7. Removing a claim cannot leave an orphaned foregrounding row.
8. Foregrounding a classification does not automatically create a care, access,
   ownership, legality or restitution conclusion.

## Competency questions for first-class Concepts

Concepts will be reconsidered only through a separate ADR supported by concrete
cases. The following questions determine whether they are needed:

1. Must users access a shared Concept record independently of any particular
   item?
2. Must one set of attributed definitions be maintained and reused across
   several item records?
3. Must MoSA query across different terms, spellings or translations that a
   documented interpretation treats as the same Concept?
4. Must definitions of a Concept be revised, superseded or contested
   independently of its application to particular items?
5. Must MoSA answer structured questions about precise relationships among
   Concepts that cannot be answered from sources and evidence excerpts?
6. Must an explicit protocol or decision apply to a category of items through a
   shared Concept rather than through separately identified items?
7. Would representing the requirement through foregrounded literal claims,
   evidence and contextual sources cause material duplication, information loss
   or an inability to answer a required query?

A first-class Concept is justified only when a named competency case requires an
addressable shared Concept and cannot be represented cleanly by attributed
literal claims, evidence and sources. Cultural significance alone does not
determine the database representation.

If Concepts are later introduced, the following decisions already apply:

- a Concept is an addressable project record, not a declaration of universal or
  community-wide consensus;
- names and descriptions of a Concept are attributed claims, not canonical
  columns;
- applying a Concept to an item remains an attributed and evidenced claim;
- original literal wording is preserved even when a later interpretation maps
  it to a Concept;
- no Concept is intrinsically primary;
- uncertain equivalence does not justify merging Concept identities;
- Concept relationships use specific, competency-derived predicates rather than
  a generic `related_to` relation;
- classifications do not automatically determine care, access or restitution
  decisions.

Candidate terms supplied during the discussion are research inputs, not an
automatically approved Concept corpus. An explicitly unconfirmed term or
relationship cannot acquire special database status merely by appearing on the
candidate list.

## Consequences

### Benefits

- MoSA can express its editorial position without converting that position into
  an ontological truth claim.
- Situated perspectives can shape the reader's first encounter with an item
  rather than being present only as undifferentiated additional data.
- The implementation adds one relation and relies on the existing claim,
  evidence and status model.
- Literal classifications remain sufficient and retain their exact wording.
- The design does not assume that all culturally important terms form one kind
  of hierarchy.
- A later Concept model can be added without replacing the foregrounding model
  or discarding existing claims.

### Costs

- The table does not record why, when or by whom a claim was foregrounded.
- Foregrounding initially applies to one default presentation only.
- It provides no explicit ordering when several claims are foregrounded.
- General definitions may remain in contextual sources rather than as reusable
  database subjects unless a later competency justifies Concepts.

These costs are accepted because none currently prevents MoSA from satisfying
the agreed foregrounding requirement. Adding speculative fields now would make
the model more difficult to understand and maintain without answering an
established question.

## Intellectual context

This decision draws on work that treats knowledge and description as situated,
accountable practices rather than neutral views from nowhere:

- Donna Haraway, [“Situated Knowledges: The Science Question in Feminism and
  the Privilege of Partial Perspective”](https://commons.princeton.edu/hum583-f21/wp-content/uploads/sites/283/2021/08/Haraway-Situated-Knowledges.pdf),
  *Feminist Studies* 14, no. 3 (1988).
- Alison Wylie, [“What Knowers Know Well: Standpoint Theory and Gender
  Archaeology”](https://revistas.usp.br/ss/en/article/view/133641),
  *Scientiae Studia* 15, no. 1 (2017).
- Stephanie Russo Carroll et al., [“The CARE Principles for Indigenous Data
  Governance”](https://doi.org/10.5334/dsj-2020-043), *Data Science Journal* 19
  (2020).
- Local Contexts, [“Traditional Knowledge
  Labels”](https://localcontexts.org/labels/traditional-knowledge-labels/).
- Tonia Sutherland and Alyssa Purcell, [“A Weapon and a Tool: Decolonizing
  Description and Embracing Redescription as Liberatory Archival
  Praxis”](https://www.jstor.org/stable/48645295), *The International Journal of
  Information, Diversity, & Inclusion* 5, no. 1 (2021).
- Linda Martín Alcoff, [“The Problem of Speaking for
  Others”](https://depts.washington.edu/egonline/wordpress/wp-content/uploads/2010/05/Alcoff-Reading.pdf),
  *Cultural Critique* 20 (1991–1992).

These sources inform the distinction between preserving plural claims,
recognising the epistemic significance of social position, supporting agency in
description and making accountable editorial choices. They do not determine
which particular MoSA claim should be foregrounded; that remains a situated
project decision.

## Principle

> Preserve attributed plurality, accept responsibility for editorial salience,
> and introduce first-class Concepts only when a demonstrated competency
> requires them.
