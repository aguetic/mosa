# Phase 3 restitution case-management boundary

Status: proposed active vertical slice, to be validated through two restitution competency cases.

## Goal

Provide a pragmatic case-management system for recording restitution, repatriation and return work concerning collection items.

Phase 3 records the cases being managed, the items they concern, the parties involved, the actions that occurred, the documents held and the current operational state of the case. It does not decide whether a request is historically, legally or morally justified.

## Relationship to the existing model

### Shared identities

The restitution module reuses existing identities for:

- items;
- people;
- communities;
- organisations;
- institutions.

A restitution case is linked to one or more existing item identities. Case parties link to existing agent identities.

### Independence from provenance

Provenance events and restitution cases are independently related to the same item.

Phase 3 does not require direct database links between restitution cases or actions and provenance events. A restitution request may rely on provenance research in practice, but that interpretive relationship is not stored unless a later competency case demonstrates a concrete query need.

Recording a completed handover in restitution does not automatically create or update:

- a provenance event;
- `moved_item`;
- `transferred_item`;
- `held_by`;
- `located_at`.

Those records remain the responsibility of their existing modules.

### Independence from claims

Routine restitution case-management facts are stored directly and do not use `knowledge.claim`.

Examples include:

- a case was opened;
- a request was received;
- an organisation is a requester or respondent in the case;
- a meeting took place;
- a recommendation was recorded;
- a decision was recorded;
- a handover was completed;
- the case is open or closed.

The claims module remains available elsewhere for substantive historical, cultural, legal or political assertions that require attribution or evidence. Phase 3 does not create restitution claims merely to represent the administrative history of a case.

Item and agent identities used by a fixture may still depend on Phase 1 claims for their labels or classifications. That does not make restitution actions claim-based.

## Included

### Case records

A case is a stable operational record for a restitution, repatriation or return process.

A case may:

- be initiated by a holding institution or by an external requester;
- concern one or more items;
- involve several parties in the same or different roles;
- remain open without a decision;
- close after a decision, implementation or other administrative resolution.

The initial slice requires only the operational statuses:

- `open`;
- `closed`.

Additional workflow statuses require a failing competency test or a recorded decision.

### Case-item scope

A case-item link means:

> This case concerns this item.

It does not mean:

- the requester owns the item;
- the request is valid;
- the item must be returned;
- a transfer has occurred;
- the item's current custody or location has changed.

### Case parties

A party is an existing agent associated with a case in an operational role.

The initial cases require roles equivalent to:

- initiator;
- requester;
- respondent;
- advisor;
- decision maker;
- recipient.

The same agent may hold more than one role. Several agents may share one role.

Party roles describe participation in the case. They do not establish legal standing, authority, ownership or community representativeness beyond what the case record needs to manage the process.

### Case actions

Actions form the administrative history of a case.

The initial cases require broad action kinds equivalent to:

- outreach;
- request;
- engagement;
- recommendation;
- decision;
- handover.

Actions have stable identities, direct descriptions and optional structured dates. The date representation must support exact, month-level, year-level and unrecorded dates without inventing precision.

Actions may have participating agents with action-specific roles. A party's role in one action does not need to be inferred from its general role in the case.

A request, recommendation, decision and handover are separate actions. None is inferred from another.

Phase 3 records request actions and their documents directly. It does not initially classify requests into canonical remedy categories such as return, repatriation, long-term loan, shared custody, access or removal from display. What was requested is answered from the action description and associated document. A structured requested-remedy field should be added only if later population shows a concrete cross-case query need.

### Case documents

Documents are administrative records associated with a case. They may also be linked to one or more actions through a separate association.

Examples include:

- an incoming request;
- an acknowledgement;
- meeting notes;
- a recommendation;
- a decision record;
- a transfer agreement;
- a handover receipt;
- a public institutional statement.

A document may remain case-level only, for example a general process report. A document may also relate to several actions when one source covers recommendation and decision, or several stages of a process. Assigning each document to exactly one action would be arbitrary in those cases.

A case document is not automatically claim evidence. Phase 3 may reuse an existing source or file identity rather than duplicating document content.

### Read-only exploration

The item page should show only the existence of linked restitution cases: title, reference, operational status and a link to the case. It should not narrate process or summarise action counts.

The case page should begin with minimal metadata — title, reference, status and concerned items — then move directly into parties and actions. Related documents appear beneath their actions; remaining case-level documents appear separately. Absence of a recorded decision or handover must remain visible from the action history.

Do not store a free-text case summary or generic notes fields. Title identifies the case; actions and documents record what happened. A public or generated summary may later be derived as a presentation projection. A more specific annotation field can be added later when a test case identifies information that cannot otherwise be represented.

The explorer must not describe a case as approved, denied, successful, rightful, illegitimate or complete unless the corresponding operational record exists.

## Candidate canonical storage

The initial implementation is expected to pressure a small set of restitution-owned structures:

- `restitution.case_record`;
- `restitution.case_item`;
- `restitution.case_party`;
- `restitution.case_action`;
- `restitution.action_party`;
- `restitution.case_document`;
- `restitution.action_document`.

The exact columns and database API should be chosen by the competency tests. The following concepts must remain directly queryable:

- case reference, title, status, opened date and closed date;
- concerned item identities;
- party identities and roles;
- action kind, description and date;
- action participants and roles;
- document identity at case level;
- optional many-to-many links from documents to actions.

Restitution cases and actions are not required to be `entities.entity` rows in the initial slice.

## Invariants

- Restitution is an operational case-management module, not a historical truth-resolution module.
- Routine case facts do not require `knowledge.claim` or claim evidence.
- Cases and provenance events are linked through shared item identity, not direct Phase 3 relationships.
- A case-item link does not imply ownership, entitlement, validity or an expected outcome.
- A case may be institution-initiated; `requester` is not required when a case is opened.
- Initiation and receipt of a formal request are separate actions.
- Several requesters, respondents or recipients may participate in one case.
- Request, recommendation, decision, handover and closure remain distinct.
- Requests are not classified into canonical remedy categories in the initial slice.
- A request does not imply approval, refusal, transfer, movement or a change of custody.
- A recommendation does not imply a decision.
- A decision does not imply implementation.
- A handover record does not by itself update provenance or current item state.
- The absence of a decision or handover action must not be rendered as a refusal.
- Case status is an internal operational state, not a judgment about the merits of the case.
- Documents support administration of the case and are not automatically epistemic evidence.
- Partial or unknown action dates remain partial or unknown.
- Phase 3 does not establish legal title, rightful ownership, consent, authority or a preferred historical narrative.

## Initial competency cases

Implementation order:

1. Case 10: Return of the Aberdeen Head of an Oba
2. Case 11: Request for the return of Hoa Hakananaiʻa

### Case 10: completed, institution-initiated process

Case 10 establishes the core case-management structures through a completed process that did not begin with an unsolicited external request.

It tests:

- proactive institutional initiation;
- a later formal claim;
- several parties with different roles;
- recommendation and decision as separate actions;
- more than one handover action;
- a closed case;
- no automatic provenance or current-state updates.

### Case 11: open, request-led process

Case 11 extends the slice with a jointly submitted request and subsequent engagement without a recorded decision or handover.

It tests:

- several requesters;
- an institutional respondent;
- a request action and its incoming request document;
- meetings and reciprocal visits as engagement actions;
- an open case;
- no inferred refusal, decision, transfer or return;
- reuse of the existing Hoa Hakananaiʻa item identity from Case 07.

Together, the two cases establish that Phase 3 can represent both a completed institution-led process and an open request-led process without using the claims model for routine administration.

## Deferred

- direct restitution-to-provenance-event links;
- ownership and legal-title determinations;
- moral or legal assessment of requests;
- claimant eligibility or standing rules;
- community-representation validation;
- legal-jurisdiction modelling;
- configurable institutional workflows;
- deadlines, reminders and task assignment;
- approvals requiring several internal signatories;
- document versioning and digital signatures;
- financial and logistical management;
- automatic creation of provenance events or current-state claims;
- public submission forms;
- write-enabled explorer interfaces;
- general-purpose claims or evidence attached to restitution actions;
- canonical requested-remedy classification;
- multi-remedy and conditional-settlement modelling;
- appeals, reopened cases and competing simultaneous requests.

New Phase 3 structures require a failing restitution competency test or a recorded decision.
