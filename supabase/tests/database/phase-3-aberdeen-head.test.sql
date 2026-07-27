begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select no_plan();

-- Minimal Phase 3 schema contract.

select has_schema(
    'restitution',
    'the restitution schema exists'
);

select has_table(
    'restitution',
    'case_record',
    'restitution.case_record exists'
);

select has_table(
    'restitution',
    'case_item',
    'restitution.case_item exists'
);

select has_table(
    'restitution',
    'case_party',
    'restitution.case_party exists'
);

select has_table(
    'restitution',
    'case_action',
    'restitution.case_action exists'
);

select has_table(
    'restitution',
    'action_party',
    'restitution.action_party exists'
);

select has_table(
    'restitution',
    'case_document',
    'restitution.case_document exists'
);

select has_table(
    'restitution',
    'action_document',
    'restitution.action_document exists'
);

select ok(
    not exists (
        select 1
        from information_schema.columns
        where table_schema = 'restitution'
          and table_name = 'case_record'
          and column_name = 'requested_remedy'
    ),
    'Phase 3 does not classify requests into a canonical remedy field'
);

select ok(
    to_regclass('restitution.action_provenance_event') is null,
    'Phase 3 introduces no direct restitution-to-provenance link table'
);

-- Stable case and item scope.

select is(
    (
        select count(*)::integer
        from restitution.case_record
        where id = '91000000-0000-4000-8000-000000000001'::uuid
          and reference = 'RST-001'
          and title = 'Return of the Aberdeen Head of an Oba'
    ),
    1,
    'one stable Aberdeen restitution case is recorded'
);

select is(
    (
        select status
        from restitution.case_record
        where id = '91000000-0000-4000-8000-000000000001'::uuid
    ),
    'closed',
    'the Aberdeen case is operationally closed'
);

select ok(
    exists (
        select 1
        from restitution.case_record
        where id = '91000000-0000-4000-8000-000000000001'::uuid
          and opened_start = date '2020-01-01'
          and opened_end = date '2020-12-31'
          and opened_precision = 'year'
    ),
    'the case opening retains year-level precision'
);

select ok(
    exists (
        select 1
        from restitution.case_record
        where id = '91000000-0000-4000-8000-000000000001'::uuid
          and closed_start = date '2022-02-19'
          and closed_end = date '2022-02-19'
          and closed_precision = 'day'
    ),
    'the case closure is recorded as an exact day'
);

select is(
    (
        select count(*)::integer
        from restitution.case_item
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and item_id = '36000000-0000-4000-8000-000000000001'::uuid
    ),
    1,
    'the case concerns one stable Aberdeen item identity'
);

select ok(
    exists (
        select 1
        from entities.item as item
        join knowledge.claim as claim
          on claim.subject_id = item.id
         and claim.predicate = 'has_name'
         and claim.literal_value ->> 'value' = 'Head of an Oba — University of Aberdeen'
         and claim.asserted_by_agent_id = '16000000-0000-4000-8000-000000000001'::uuid
        where item.id = '36000000-0000-4000-8000-000000000001'::uuid
          and item.item_kind = 'artefact'
    ),
    'the concerned object is an ordinary Phase 1 item named by the University of Aberdeen'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence as evidence
        where evidence.claim_id = '56000000-0000-4000-8000-000000000008'::uuid
          and evidence.source_id = '46000000-0000-4000-8000-000000000001'::uuid
          and evidence.relationship = 'supports'
    ),
    'the object name claim is supported by the University of Aberdeen institutional record'
);

-- Case roles allow institution initiation, a later claimant and repeated roles.

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and agent_id = '16000000-0000-4000-8000-000000000001'::uuid
          and role = 'initiator'
    ),
    1,
    'the University is recorded as the case initiator'
);

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and agent_id = '16000000-0000-4000-8000-000000000001'::uuid
          and role = 'respondent'
    ),
    1,
    'the University can also be the respondent'
);

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and agent_id = '16000000-0000-4000-8000-000000000002'::uuid
          and role = 'requester'
    ),
    1,
    'the later formal claimant is recorded separately from the initiator'
);

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and agent_id = '16000000-0000-4000-8000-000000000003'::uuid
          and role in ('advisor', 'recipient')
    ),
    2,
    'one institution may hold more than one operational case role'
);

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
    ),
    9,
    'the fixture records all required case-role assignments'
);

-- Separate actions and partial dates.

select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
    ),
    6,
    'the case has six distinct administrative actions'
);

select results_eq(
    $$
        select sequence_number, action_kind
        from restitution.case_action
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
        order by sequence_number
    $$,
    $$
        values
            (1, 'outreach'::text),
            (2, 'request'::text),
            (3, 'recommendation'::text),
            (4, 'decision'::text),
            (5, 'handover'::text),
            (6, 'handover'::text)
    $$,
    'the action sequence distinguishes initiation, claim, recommendation, decision and two handovers'
);

select ok(
    exists (
        select 1
        from restitution.case_action
        where id = '93000000-0000-4000-8000-000000000001'::uuid
          and occurred_start = date '2020-01-01'
          and occurred_end = date '2020-12-31'
          and occurred_precision = 'year'
    ),
    'institutional outreach retains year-level precision'
);

select ok(
    exists (
        select 1
        from restitution.case_action
        where id = '93000000-0000-4000-8000-000000000002'::uuid
          and occurred_start is null
          and occurred_end is null
          and occurred_precision is null
    ),
    'the formal request date remains unrecorded'
);

select ok(
    exists (
        select 1
        from restitution.case_action
        where id = '93000000-0000-4000-8000-000000000003'::uuid
          and action_kind = 'recommendation'
    )
    and exists (
        select 1
        from restitution.case_action
        where id = '93000000-0000-4000-8000-000000000004'::uuid
          and action_kind = 'decision'
    ),
    'recommendation and decision remain separate actions'
);

select ok(
    exists (
        select 1
        from restitution.case_action
        where id = '93000000-0000-4000-8000-000000000004'::uuid
          and occurred_start = date '2021-03-23'
          and occurred_end = date '2021-03-23'
          and occurred_precision = 'day'
    ),
    'the governing-body decision has its own recorded date'
);

select results_eq(
    $$
        select occurred_start
        from restitution.case_action
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and action_kind = 'handover'
        order by sequence_number
    $$,
    $$
        values
            (date '2021-10-28'),
            (date '2022-02-19')
    $$,
    'the Aberdeen and Benin City handovers remain distinct dated actions'
);

select is(
    (
        select count(*)::integer
        from restitution.action_party
        where action_id = '93000000-0000-4000-8000-000000000005'::uuid
          and role = 'recipient'
    ),
    2,
    'the Aberdeen handover records two recipient institutions'
);

select is(
    (
        select count(*)::integer
        from restitution.action_party
        where action_id = '93000000-0000-4000-8000-000000000006'::uuid
          and agent_id = '16000000-0000-4000-8000-000000000006'::uuid
          and role = 'recipient'
    ),
    1,
    'the final handover records the Royal Court as recipient'
);

select is(
    (
        select count(*)::integer
        from restitution.action_party
        where action_id in (
            select id
            from restitution.case_action
            where case_id = '91000000-0000-4000-8000-000000000001'::uuid
        )
    ),
    10,
    'action-specific participation is recorded independently from case roles'
);

select ok(
    (
        select closed_end
        from restitution.case_record
        where id = '91000000-0000-4000-8000-000000000001'::uuid
    ) >= (
        select max(occurred_end)
        from restitution.case_action
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and action_kind = 'handover'
    ),
    'the case does not close before its final recorded handover'
);

-- Documents are case records, not claim evidence.
-- Action links are many-to-many and optional.

select is(
    (
        select count(*)::integer
        from restitution.case_document
        where case_id = '91000000-0000-4000-8000-000000000001'::uuid
    ),
    4,
    'four administrative documents are linked to the case'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document
        where document_id = '95000000-0000-4000-8000-000000000001'::uuid
          and action_id in (
              '93000000-0000-4000-8000-000000000003'::uuid,
              '93000000-0000-4000-8000-000000000004'::uuid
          )
    ),
    2,
    'the institutional announcement relates to recommendation and decision'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document
        where document_id = '95000000-0000-4000-8000-000000000002'::uuid
    ),
    6,
    'the process account relates to every recorded action'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document
        where action_id in (
            '93000000-0000-4000-8000-000000000005'::uuid,
            '93000000-0000-4000-8000-000000000006'::uuid
        )
          and document_id in (
              '95000000-0000-4000-8000-000000000003'::uuid,
              '95000000-0000-4000-8000-000000000004'::uuid
          )
    ),
    2,
    'each handover has its own administrative document link'
);

select is(
    (
        select count(*)::integer
        from restitution.case_document as document
        where document.case_id = '91000000-0000-4000-8000-000000000001'::uuid
          and not exists (
              select 1
              from restitution.action_document as action_document
              where action_document.document_id = document.id
          )
    ),
    0,
    'Aberdeen fixture documents each have at least one action link'
);

select is(
    (
        select count(*)::integer
        from entities.source
        where id >= '46000000-0000-4000-8000-000000000001'::uuid
          and id <= '46000000-0000-4000-8000-000000000004'::uuid
    ),
    4,
    'case documents reuse ordinary Phase 1 source identities'
);

-- Restitution does not depend on claims or mutate provenance/current state.

select is(
    (
        select count(*)::integer
        from entities.entity
        where id >= '93000000-0000-4000-8000-000000000001'::uuid
          and id <= '93000000-0000-4000-8000-000000000006'::uuid
    ),
    0,
    'restitution actions are not entity or claim anchors'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id in (
            '16000000-0000-4000-8000-000000000001'::uuid,
            '16000000-0000-4000-8000-000000000002'::uuid,
            '16000000-0000-4000-8000-000000000003'::uuid,
            '16000000-0000-4000-8000-000000000004'::uuid,
            '16000000-0000-4000-8000-000000000005'::uuid,
            '16000000-0000-4000-8000-000000000006'::uuid,
            '16000000-0000-4000-8000-000000000007'::uuid,
            '36000000-0000-4000-8000-000000000001'::uuid,
            '46000000-0000-4000-8000-000000000001'::uuid,
            '46000000-0000-4000-8000-000000000002'::uuid,
            '46000000-0000-4000-8000-000000000003'::uuid,
            '46000000-0000-4000-8000-000000000004'::uuid
        )
          and predicate <> 'has_name'
    ),
    0,
    'routine restitution facts create no knowledge claims'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where object_entity_id = '36000000-0000-4000-8000-000000000001'::uuid
          and predicate in ('moved_item', 'transferred_item')
    ),
    0,
    'handover actions do not automatically create provenance movement or transfer claims'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '36000000-0000-4000-8000-000000000001'::uuid
          and predicate in ('held_by', 'located_at')
    ),
    0,
    'handover actions do not automatically update current custody or location'
);

select * from finish();

rollback;
