begin;

select plan(38);

-- Reuse the existing Hoa Hakananaiʻa identity.
select is(
    (
        select count(*)::integer
        from entities.item
        where id = '30000000-0000-4000-8000-000000000001'::uuid
    ),
    1,
    'the existing Hoa Hakananaiʻa item is reused'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate = 'has_name'
          and status = 'active'
          and literal_value ->> 'value' = 'Hoa Hakananaiʻa'
    ),
    1,
    'the fixture does not create a duplicate Hoa Hakananaiʻa identity'
);

select is(
    (
        select count(*)::integer
        from restitution.case_item
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and item_id = '30000000-0000-4000-8000-000000000001'::uuid
    ),
    1,
    'one restitution case links directly to the existing Hoa item'
);

select is(
    (
        select reference
        from restitution.case_record
        where id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    'RST-002',
    'the case reference is RST-002'
);

select is(
    (
        select title
        from restitution.case_record
        where id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    'Request for the return of Hoa Hakananaiʻa',
    'the case has the expected title'
);

select is(
    (
        select status
        from restitution.case_record
        where id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    'open',
    'the case is operationally open'
);

select ok(
    (
        select closed_start is null
           and closed_end is null
           and closed_precision is null
        from restitution.case_record
        where id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    'the open case has no closed date'
);

-- Three distinct requesters and one respondent.
select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and role = 'requester'
    ),
    3,
    'three requester roles are recorded'
);

select is(
    (
        select count(distinct agent_id)::integer
        from restitution.case_party
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and role = 'requester'
    ),
    3,
    'the requester roles belong to three distinct agents'
);

select is(
    (
        select count(*)::integer
        from restitution.case_party
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and role = 'respondent'
          and agent_id = '10000000-0000-4000-8000-000000000002'::uuid
    ),
    1,
    'the British Museum is the respondent'
);

select is(
    (
        select count(*)::integer
        from entities.agent
        where id in (
            '17000000-0000-4000-8000-000000000001'::uuid,
            '17000000-0000-4000-8000-000000000002'::uuid,
            '17000000-0000-4000-8000-000000000003'::uuid
        )
    ),
    3,
    'the three requester organisations remain separate agents'
);

-- Action sequence and partial dates.
select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    4,
    'the case has one request and three engagement actions'
);

select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and action_kind = 'request'
    ),
    1,
    'one request action is recorded'
);

select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and action_kind = 'engagement'
    ),
    3,
    'three later engagement actions are recorded'
);

select is(
    (
        select description
        from restitution.case_action
        where id = '98000000-0000-4000-8000-000000000001'::uuid
    ),
    'Joint written request to begin talks concerning the return of Hoa Hakananaiʻa.',
    'the request description records what was requested'
);

select ok(
    (
        select occurred_start = '2018-07-01'::date
           and occurred_end = '2018-07-31'::date
           and occurred_precision = 'month'
        from restitution.case_action
        where id = '98000000-0000-4000-8000-000000000001'::uuid
    ),
    'the request preserves July 2018 month precision'
);

select ok(
    (
        select occurred_start = '2018-11-01'::date
           and occurred_end = '2018-11-30'::date
           and occurred_precision = 'month'
        from restitution.case_action
        where id = '98000000-0000-4000-8000-000000000002'::uuid
    ),
    'the delegation visit preserves November 2018 month precision'
);

select ok(
    (
        select occurred_start = '2019-06-01'::date
           and occurred_end = '2019-06-30'::date
           and occurred_precision = 'month'
        from restitution.case_action
        where id = '98000000-0000-4000-8000-000000000003'::uuid
    ),
    'the reciprocal visit preserves June 2019 month precision'
);

select ok(
    (
        select occurred_start = '2019-08-01'::date
           and occurred_end = '2019-08-31'::date
           and occurred_precision = 'month'
        from restitution.case_action
        where id = '98000000-0000-4000-8000-000000000004'::uuid
    ),
    'the collections visit preserves August 2019 month precision'
);

select results_eq(
    $$
        select sequence_number
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
        order by sequence_number
    $$,
    $$ values (1), (2), (3), (4) $$,
    'the actions have one explicit administrative sequence'
);

-- The request action keeps all three requesters directly queryable.
select is(
    (
        select count(*)::integer
        from restitution.action_party
        where action_id = '98000000-0000-4000-8000-000000000001'::uuid
          and role = 'actor'
    ),
    3,
    'all three requesting organisations are actors in the request action'
);

select is(
    (
        select count(distinct agent_id)::integer
        from restitution.action_party
        where action_id = '98000000-0000-4000-8000-000000000001'::uuid
          and role = 'actor'
    ),
    3,
    'the request actors are three distinct agents'
);

select is(
    (
        select count(*)::integer
        from restitution.action_party
        where action_id = '98000000-0000-4000-8000-000000000001'::uuid
          and role = 'recipient'
          and agent_id = '10000000-0000-4000-8000-000000000002'::uuid
    ),
    1,
    'the British Museum is the request recipient'
);

-- Documents are administrative records. The request reference is attached to
-- the request action. The Museum page remains attached to the case and is also
-- linked to every action whose information it supplies.
select is(
    (
        select count(*)::integer
        from restitution.case_document
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    2,
    'two case documents are recorded'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document as action_document
        join restitution.case_document as document
          on document.id = action_document.document_id
        where action_document.action_id = '98000000-0000-4000-8000-000000000001'::uuid
          and document.document_role = 'incoming request'
    ),
    1,
    'the incoming request reference is attached to the request action'
);

select is(
    (
        select count(*)::integer
        from restitution.case_document as document
        where document.case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and document.document_role = 'public case-status account'
          and document.source_id = '47000000-0000-4000-8000-000000000001'::uuid
    ),
    1,
    'the British Museum page remains a case-level document'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document as action_document
        join restitution.case_document as document
          on document.id = action_document.document_id
        where document.case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and document.source_id = '47000000-0000-4000-8000-000000000001'::uuid
          and document.document_role = 'public case-status account'
    ),
    4,
    'the British Museum page is linked to all four actions it documents'
);

select is(
    (
        select count(*)::integer
        from restitution.action_document
        where action_id = '98000000-0000-4000-8000-000000000001'::uuid
    ),
    2,
    'the request action exposes both the incoming request and the public account'
);

select is(
    (
        select count(distinct action_document.action_id)::integer
        from restitution.action_document as action_document
        join restitution.case_document as document
          on document.id = action_document.document_id
        where document.case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and document.source_id = '47000000-0000-4000-8000-000000000001'::uuid
          and action_document.action_id in (
              '98000000-0000-4000-8000-000000000002'::uuid,
              '98000000-0000-4000-8000-000000000003'::uuid,
              '98000000-0000-4000-8000-000000000004'::uuid
          )
    ),
    3,
    'each engagement action exposes the British Museum public account'
);

select is(
    (
        select count(*)::integer
        from restitution.case_action action
        where action.case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and not exists (
              select 1
              from restitution.action_document document
              where document.case_id = action.case_id
                and document.action_id = action.id
          )
    ),
    0,
    'every recorded action has at least one visible related document'
);

-- Absence is represented by absent actions, not inferred statuses.
select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and action_kind = 'recommendation'
    ),
    0,
    'no recommendation action is recorded'
);

select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and action_kind = 'decision'
    ),
    0,
    'no decision action is recorded'
);

select is(
    (
        select count(*)::integer
        from restitution.case_action
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
          and action_kind = 'handover'
    ),
    0,
    'no handover action is recorded'
);

select ok(
    not exists (
        select 1
        from restitution.case_record
        where id = '97000000-0000-4000-8000-000000000002'::uuid
          and status in ('denied', 'accepted', 'successful', 'failed', 'completed', 'unresolved')
    ),
    'no inferred outcome status is stored'
);

-- Restitution actions are not claims and do not create provenance consequences.
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id in (
            '98000000-0000-4000-8000-000000000001'::uuid,
            '98000000-0000-4000-8000-000000000002'::uuid,
            '98000000-0000-4000-8000-000000000003'::uuid,
            '98000000-0000-4000-8000-000000000004'::uuid
        )
    ),
    0,
    'no restitution action is represented as a knowledge claim'
);

select is(
    (
        select count(*)::integer
        from provenance.event
        where id >= '98000000-0000-4000-8000-000000000000'::uuid
          and id <  '98000000-0000-4000-8000-000000000100'::uuid
    ),
    0,
    'the restitution fixture creates no provenance events'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where id >= '57000000-0000-4000-8000-000000000000'::uuid
          and id <  '57000000-0000-4000-8000-000000000100'::uuid
          and predicate in ('moved_item', 'transferred_item', 'held_by', 'located_at')
    ),
    0,
    'the fixture adds no movement, transfer, custody or location claims'
);

select is(
    (
        select count(*)::integer
        from restitution.case_item
        where case_id = '97000000-0000-4000-8000-000000000002'::uuid
    ),
    1,
    'the initial case scope contains Hoa Hakananaiʻa alone'
);

select * from finish();
rollback;
