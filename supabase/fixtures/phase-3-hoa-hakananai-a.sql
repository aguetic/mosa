-- Deterministic local/test fixture for Phase 3 case 11:
-- Request for the return of Hoa Hakananaiʻa.
--
-- This fixture reuses the Phase 1 Hoa Hakananaiʻa item and British Museum
-- agent. It adds one open restitution case, three distinct requester agents,
-- one request action, three engagement actions and two administrative
-- source records. The British Museum public account remains attached to the
-- case and is also linked to every action it documents. It does not create
-- provenance events or routine case claims.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if not exists (
        select 1
        from entities.item
        where id = '30000000-0000-4000-8000-000000000001'::uuid
    ) then
        raise exception
            'Case 11 requires the existing Hoa Hakananaiʻa item.';
    end if;

    if not exists (
        select 1
        from entities.agent
        where id = '10000000-0000-4000-8000-000000000002'::uuid
    ) then
        raise exception
            'Case 11 requires the existing British Museum agent.';
    end if;
end;
$$;

-- Repeatable fixture cleanup within the reserved Case 11 UUID ranges.
delete from restitution.action_document
where id >= 'c7000000-0000-4000-8000-000000000000'::uuid
  and id <  'c7000000-0000-4000-8000-000000000100'::uuid;

delete from restitution.case_document
where id >= 'b7000000-0000-4000-8000-000000000000'::uuid
  and id <  'b7000000-0000-4000-8000-000000000100'::uuid;

delete from restitution.action_party
where id >= 'a7000000-0000-4000-8000-000000000000'::uuid
  and id <  'a7000000-0000-4000-8000-000000000100'::uuid;

delete from restitution.case_action
where id >= '98000000-0000-4000-8000-000000000000'::uuid
  and id <  '98000000-0000-4000-8000-000000000100'::uuid;

delete from restitution.case_party
where id >= '99000000-0000-4000-8000-000000000000'::uuid
  and id <  '99000000-0000-4000-8000-000000000100'::uuid;

delete from restitution.case_item
where case_id = '97000000-0000-4000-8000-000000000002'::uuid;

delete from restitution.case_record
where id = '97000000-0000-4000-8000-000000000002'::uuid;

delete from knowledge.claim
where id >= '57000000-0000-4000-8000-000000000000'::uuid
  and id <  '57000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '47000000-0000-4000-8000-000000000000'::uuid
  and id <  '47000000-0000-4000-8000-000000000100'::uuid;

delete from entities.agent
where id >= '17000000-0000-4000-8000-000000000000'::uuid
  and id <  '17000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
    '17000000-0000-4000-8000-000000000001'::uuid,
    '17000000-0000-4000-8000-000000000002'::uuid,
    '17000000-0000-4000-8000-000000000003'::uuid,
    '47000000-0000-4000-8000-000000000001'::uuid,
    '47000000-0000-4000-8000-000000000002'::uuid
);

-- The requesters remain three distinct organisations.
insert into entities.entity (id, entity_type)
values
    ('17000000-0000-4000-8000-000000000001', 'agent'),
    ('17000000-0000-4000-8000-000000000002', 'agent'),
    ('17000000-0000-4000-8000-000000000003', 'agent'),
    ('47000000-0000-4000-8000-000000000001', 'source'),
    ('47000000-0000-4000-8000-000000000002', 'source');

insert into entities.agent (id, agent_kind)
values
    ('17000000-0000-4000-8000-000000000001', 'organisation'),
    ('17000000-0000-4000-8000-000000000002', 'organisation'),
    ('17000000-0000-4000-8000-000000000003', 'organisation');

insert into entities.source (id, source_kind, reference, retrieved_at)
values
    (
        '47000000-0000-4000-8000-000000000001',
        'institutional_webpage',
        'https://www.britishmuseum.org/about-us/british-museum-story/contested-objects-collection/moai',
        null
    ),
    (
        '47000000-0000-4000-8000-000000000002',
        'correspondence_reference',
        'urn:mosa:restitution:RST-002:written-request:2018-07',
        null
    );

-- Identity labels remain ordinary entity claims. They are not restitution
-- action records and carry no claim-evidence links in this fixture.
insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
values
    (
        '57000000-0000-4000-8000-000000000001',
        '17000000-0000-4000-8000-000000000001',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Council of Elders of Rapa Nui',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '57000000-0000-4000-8000-000000000002',
        '17000000-0000-4000-8000-000000000002',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'CODEIPA',
            'language', 'es'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '57000000-0000-4000-8000-000000000003',
        '17000000-0000-4000-8000-000000000003',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Municipality of Rapa Nui',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '57000000-0000-4000-8000-000000000004',
        '47000000-0000-4000-8000-000000000001',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'British Museum: Moai',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '57000000-0000-4000-8000-000000000005',
        '47000000-0000-4000-8000-000000000002',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'July 2018 written request concerning Hoa Hakananaiʻa',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

insert into restitution.case_record (
    id,
    reference,
    title,
    status,
    opened_start,
    opened_end,
    opened_precision,
    closed_start,
    closed_end,
    closed_precision
)
values (
    '97000000-0000-4000-8000-000000000002',
    'RST-002',
    'Request for the return of Hoa Hakananaiʻa',
    'open',
    '2018-07-01',
    '2018-07-31',
    'month',
    null,
    null,
    null
);

insert into restitution.case_item (case_id, item_id)
values (
    '97000000-0000-4000-8000-000000000002',
    '30000000-0000-4000-8000-000000000001'
);

insert into restitution.case_party (id, case_id, agent_id, role)
values
    (
        '99000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002',
        '17000000-0000-4000-8000-000000000001',
        'requester'
    ),
    (
        '99000000-0000-4000-8000-000000000002',
        '97000000-0000-4000-8000-000000000002',
        '17000000-0000-4000-8000-000000000002',
        'requester'
    ),
    (
        '99000000-0000-4000-8000-000000000003',
        '97000000-0000-4000-8000-000000000002',
        '17000000-0000-4000-8000-000000000003',
        'requester'
    ),
    (
        '99000000-0000-4000-8000-000000000004',
        '97000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000002',
        'respondent'
    );

insert into restitution.case_action (
    id,
    case_id,
    sequence_number,
    action_kind,
    description,
    occurred_start,
    occurred_end,
    occurred_precision
)
values
    (
        '98000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002',
        1,
        'request',
        'Joint written request to begin talks concerning the return of Hoa Hakananaiʻa.',
        '2018-07-01',
        '2018-07-31',
        'month'
    ),
    (
        '98000000-0000-4000-8000-000000000002',
        '97000000-0000-4000-8000-000000000002',
        2,
        'engagement',
        'A delegation from Rapa Nui made an official visit to the British Museum following the written request.',
        '2018-11-01',
        '2018-11-30',
        'month'
    ),
    (
        '98000000-0000-4000-8000-000000000003',
        '97000000-0000-4000-8000-000000000002',
        3,
        'engagement',
        'British Museum staff visited Rapa Nui to continue discussions and learn about cultural sites, the significance of the statues and community aspirations.',
        '2019-06-01',
        '2019-06-30',
        'month'
    ),
    (
        '98000000-0000-4000-8000-000000000004',
        '97000000-0000-4000-8000-000000000002',
        4,
        'engagement',
        'The British Museum hosted a Rapanui group for a research visit in the collections.',
        '2019-08-01',
        '2019-08-31',
        'month'
    );

-- The request action has all three requesting organisations and the Museum as
-- recipient. Later engagement descriptions deliberately avoid inventing a
-- stable identity for otherwise unnamed delegations or research groups.
insert into restitution.action_party (id, action_id, agent_id, role)
values
    (
        'a7000000-0000-4000-8000-000000000001',
        '98000000-0000-4000-8000-000000000001',
        '17000000-0000-4000-8000-000000000001',
        'actor'
    ),
    (
        'a7000000-0000-4000-8000-000000000002',
        '98000000-0000-4000-8000-000000000001',
        '17000000-0000-4000-8000-000000000002',
        'actor'
    ),
    (
        'a7000000-0000-4000-8000-000000000003',
        '98000000-0000-4000-8000-000000000001',
        '17000000-0000-4000-8000-000000000003',
        'actor'
    ),
    (
        'a7000000-0000-4000-8000-000000000004',
        '98000000-0000-4000-8000-000000000001',
        '10000000-0000-4000-8000-000000000002',
        'recipient'
    ),
    (
        'a7000000-0000-4000-8000-000000000005',
        '98000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000002',
        'participant'
    ),
    (
        'a7000000-0000-4000-8000-000000000006',
        '98000000-0000-4000-8000-000000000003',
        '10000000-0000-4000-8000-000000000002',
        'actor'
    ),
    (
        'a7000000-0000-4000-8000-000000000007',
        '98000000-0000-4000-8000-000000000004',
        '10000000-0000-4000-8000-000000000002',
        'participant'
    );

insert into restitution.case_document (
    id,
    case_id,
    source_id,
    document_role
)
values
    (
        'b7000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002',
        '47000000-0000-4000-8000-000000000001',
        'public case-status account'
    ),
    (
        'b7000000-0000-4000-8000-000000000002',
        '97000000-0000-4000-8000-000000000002',
        '47000000-0000-4000-8000-000000000002',
        'incoming request'
    );

insert into restitution.action_document (
    id,
    action_id,
    document_id,
    case_id
)
values
    (
        'c7000000-0000-4000-8000-000000000001',
        '98000000-0000-4000-8000-000000000001',
        'b7000000-0000-4000-8000-000000000002',
        '97000000-0000-4000-8000-000000000002'
    ),
    (
        'c7000000-0000-4000-8000-000000000002',
        '98000000-0000-4000-8000-000000000001',
        'b7000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002'
    ),
    (
        'c7000000-0000-4000-8000-000000000003',
        '98000000-0000-4000-8000-000000000002',
        'b7000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002'
    ),
    (
        'c7000000-0000-4000-8000-000000000004',
        '98000000-0000-4000-8000-000000000003',
        'b7000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002'
    ),
    (
        'c7000000-0000-4000-8000-000000000005',
        '98000000-0000-4000-8000-000000000004',
        'b7000000-0000-4000-8000-000000000001',
        '97000000-0000-4000-8000-000000000002'
    );

commit;
