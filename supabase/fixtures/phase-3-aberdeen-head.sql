-- Deterministic local/test fixture for Phase 3 case 10:
-- return of the University of Aberdeen Head of an Oba.
--
-- Restitution records are direct operational case-management facts. Item and
-- agent display labels use ordinary Phase 1 has_name claims attributed to the
-- University of Aberdeen. The fixture creates no provenance events or
-- current-state updates for the item.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if to_regclass('restitution.case_record') is null then
        raise exception
            'Case 10 requires the Phase 3 restitution migration.';
    end if;

    if exists (
        select 1
        from restitution.case_record
        where reference = 'RST-001'
          and id <> '91000000-0000-4000-8000-000000000001'::uuid
    ) then
        raise exception
            'Restitution reference RST-001 already exists under a non-fixture UUID.';
    end if;
end;
$$;

-- Reserved Phase 3 Aberdeen fixture UUID ranges are replaced on each load.
delete from restitution.case_record
where id = '91000000-0000-4000-8000-000000000001'::uuid;

delete from knowledge.claim_evidence
where id >= '66000000-0000-4000-8000-000000000000'::uuid
  and id <  '66000000-0000-4000-8000-000000000100'::uuid;

delete from knowledge.claim
where id >= '56000000-0000-4000-8000-000000000000'::uuid
  and id <  '56000000-0000-4000-8000-000000000100'::uuid;

delete from entities.item
where id = '36000000-0000-4000-8000-000000000001'::uuid;

delete from entities.agent
where id >= '16000000-0000-4000-8000-000000000000'::uuid
  and id <  '16000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '46000000-0000-4000-8000-000000000000'::uuid
  and id <  '46000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
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
);

insert into entities.entity (id, entity_type)
values
    ('16000000-0000-4000-8000-000000000001', 'agent'),
    ('16000000-0000-4000-8000-000000000002', 'agent'),
    ('16000000-0000-4000-8000-000000000003', 'agent'),
    ('16000000-0000-4000-8000-000000000004', 'agent'),
    ('16000000-0000-4000-8000-000000000005', 'agent'),
    ('16000000-0000-4000-8000-000000000006', 'agent'),
    ('16000000-0000-4000-8000-000000000007', 'agent'),
    ('36000000-0000-4000-8000-000000000001', 'item'),
    ('46000000-0000-4000-8000-000000000001', 'source'),
    ('46000000-0000-4000-8000-000000000002', 'source'),
    ('46000000-0000-4000-8000-000000000003', 'source'),
    ('46000000-0000-4000-8000-000000000004', 'source');

insert into entities.agent (id, agent_kind)
values
    ('16000000-0000-4000-8000-000000000001', 'organisation'),
    ('16000000-0000-4000-8000-000000000002', 'government_body'),
    ('16000000-0000-4000-8000-000000000003', 'government_body'),
    ('16000000-0000-4000-8000-000000000004', 'committee'),
    ('16000000-0000-4000-8000-000000000005', 'governing_body'),
    ('16000000-0000-4000-8000-000000000006', 'royal_court'),
    ('16000000-0000-4000-8000-000000000007', 'diplomatic_mission');

insert into entities.item (id, item_kind)
values
    ('36000000-0000-4000-8000-000000000001', 'artefact');

insert into entities.source (
    id,
    source_kind,
    reference
)
values
    (
        '46000000-0000-4000-8000-000000000001',
        'institutional_webpage',
        'https://aberdeenuni-newsroom.prgloo.com/news/benin-bronze-to-return'
    ),
    (
        '46000000-0000-4000-8000-000000000002',
        'sector_account',
        'https://www.museumsgalleriesscotland.org.uk/sector-story/returning-a-benin-bronze-to-its-rightful-place-benin-city/'
    ),
    (
        '46000000-0000-4000-8000-000000000003',
        'news_report',
        'https://www.channelstv.com/2021/10/29/another-uk-university-officially-hands-over-looted-benin-bronze/'
    ),
    (
        '46000000-0000-4000-8000-000000000004',
        'news_report',
        'https://www.channelstv.com/2022/02/19/oba-of-benin-takes-delivery-of-looted-okpa-ilahor-returned-from-uk/'
    );

-- Display labels only. Restitution case facts remain outside knowledge.claim.
-- Identity claims are asserted by the University of Aberdeen from its public
-- institutional record, not by an unrelated Phase 1 researcher.
insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    literal_value,
    asserted_by_agent_id
)
values
    (
        '56000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        '{"type":"text","value":"University of Aberdeen"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000002',
        '16000000-0000-4000-8000-000000000002',
        'has_name',
        null,
        '{"type":"text","value":"Federal Ministry of Information and Culture, Nigeria"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000003',
        '16000000-0000-4000-8000-000000000003',
        'has_name',
        null,
        '{"type":"text","value":"National Commission for Museums and Monuments, Nigeria"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000004',
        '16000000-0000-4000-8000-000000000004',
        'has_name',
        null,
        '{"type":"text","value":"University of Aberdeen repatriation advisory panel"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000005',
        '16000000-0000-4000-8000-000000000005',
        'has_name',
        null,
        '{"type":"text","value":"University of Aberdeen Court"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000006',
        '16000000-0000-4000-8000-000000000006',
        'has_name',
        null,
        '{"type":"text","value":"Royal Court of the Oba of Benin"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000007',
        '16000000-0000-4000-8000-000000000007',
        'has_name',
        null,
        '{"type":"text","value":"Nigeria High Commission in the United Kingdom"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000008',
        '36000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        '{"type":"text","value":"Head of an Oba — University of Aberdeen"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000009',
        '46000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        '{"type":"text","value":"University of Aberdeen announcement: Benin bronze to return"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000010',
        '46000000-0000-4000-8000-000000000002',
        'has_name',
        null,
        '{"type":"text","value":"Museums Galleries Scotland account of the Aberdeen return"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000011',
        '46000000-0000-4000-8000-000000000003',
        'has_name',
        null,
        '{"type":"text","value":"Channels Television report of the Aberdeen handover"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    ),
    (
        '56000000-0000-4000-8000-000000000012',
        '46000000-0000-4000-8000-000000000004',
        'has_name',
        null,
        '{"type":"text","value":"Channels Television report of the Benin City handover"}'::jsonb,
        '16000000-0000-4000-8000-000000000001'
    );

insert into knowledge.claim_evidence (
    id,
    claim_id,
    source_id,
    relationship,
    locator,
    excerpt
)
values
    (
        '66000000-0000-4000-8000-000000000001',
        '56000000-0000-4000-8000-000000000001',
        '46000000-0000-4000-8000-000000000001',
        'supports',
        'Title',
        'University of Aberdeen'
    ),
    (
        '66000000-0000-4000-8000-000000000002',
        '56000000-0000-4000-8000-000000000008',
        '46000000-0000-4000-8000-000000000001',
        'supports',
        'Object',
        'Benin bronze'
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
    '91000000-0000-4000-8000-000000000001',
    'RST-001',
    'Return of the Aberdeen Head of an Oba',
    'closed',
    date '2020-01-01',
    date '2020-12-31',
    'year',
    date '2022-02-19',
    date '2022-02-19',
    'day'
);

insert into restitution.case_item (
    case_id,
    item_id
)
values (
    '91000000-0000-4000-8000-000000000001',
    '36000000-0000-4000-8000-000000000001'
);

insert into restitution.case_party (
    id,
    case_id,
    agent_id,
    role
)
values
    (
        '92000000-0000-4000-8000-000000000001',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000001',
        'initiator'
    ),
    (
        '92000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000001',
        'respondent'
    ),
    (
        '92000000-0000-4000-8000-000000000003',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000002',
        'requester'
    ),
    (
        '92000000-0000-4000-8000-000000000004',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000003',
        'advisor'
    ),
    (
        '92000000-0000-4000-8000-000000000005',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000003',
        'recipient'
    ),
    (
        '92000000-0000-4000-8000-000000000006',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000004',
        'advisor'
    ),
    (
        '92000000-0000-4000-8000-000000000007',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000005',
        'decision_maker'
    ),
    (
        '92000000-0000-4000-8000-000000000008',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000006',
        'recipient'
    ),
    (
        '92000000-0000-4000-8000-000000000009',
        '91000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000007',
        'recipient'
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
        '93000000-0000-4000-8000-000000000001',
        '91000000-0000-4000-8000-000000000001',
        1,
        'outreach',
        'The University initiated discussions with relevant Nigerian parties after reviewing the object''s provenance.',
        date '2020-01-01',
        date '2020-12-31',
        'year'
    ),
    (
        '93000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001',
        2,
        'request',
        'A formal claim for the object''s return was received after the institution-initiated discussions.',
        null,
        null,
        null
    ),
    (
        '93000000-0000-4000-8000-000000000003',
        '91000000-0000-4000-8000-000000000001',
        3,
        'recommendation',
        'The University advisory panel unanimously recommended unconditional return.',
        null,
        null,
        null
    ),
    (
        '93000000-0000-4000-8000-000000000004',
        '91000000-0000-4000-8000-000000000001',
        4,
        'decision',
        'The University of Aberdeen Court supported the unconditional return of the object to Nigeria.',
        date '2021-03-23',
        date '2021-03-23',
        'day'
    ),
    (
        '93000000-0000-4000-8000-000000000005',
        '91000000-0000-4000-8000-000000000001',
        5,
        'handover',
        'The object was handed to Nigerian representatives at a ceremony in Aberdeen.',
        date '2021-10-28',
        date '2021-10-28',
        'day'
    ),
    (
        '93000000-0000-4000-8000-000000000006',
        '91000000-0000-4000-8000-000000000001',
        6,
        'handover',
        'The object was presented to Oba Ewuare II at the royal palace in Benin City.',
        date '2022-02-19',
        date '2022-02-19',
        'day'
    );

insert into restitution.action_party (
    id,
    action_id,
    agent_id,
    role
)
values
    (
        '94000000-0000-4000-8000-000000000001',
        '93000000-0000-4000-8000-000000000001',
        '16000000-0000-4000-8000-000000000001',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000002',
        '93000000-0000-4000-8000-000000000002',
        '16000000-0000-4000-8000-000000000002',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000003',
        '93000000-0000-4000-8000-000000000002',
        '16000000-0000-4000-8000-000000000001',
        'recipient'
    ),
    (
        '94000000-0000-4000-8000-000000000004',
        '93000000-0000-4000-8000-000000000003',
        '16000000-0000-4000-8000-000000000004',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000005',
        '93000000-0000-4000-8000-000000000004',
        '16000000-0000-4000-8000-000000000005',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000006',
        '93000000-0000-4000-8000-000000000005',
        '16000000-0000-4000-8000-000000000001',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000007',
        '93000000-0000-4000-8000-000000000005',
        '16000000-0000-4000-8000-000000000003',
        'recipient'
    ),
    (
        '94000000-0000-4000-8000-000000000008',
        '93000000-0000-4000-8000-000000000005',
        '16000000-0000-4000-8000-000000000007',
        'recipient'
    ),
    (
        '94000000-0000-4000-8000-000000000009',
        '93000000-0000-4000-8000-000000000006',
        '16000000-0000-4000-8000-000000000003',
        'actor'
    ),
    (
        '94000000-0000-4000-8000-000000000010',
        '93000000-0000-4000-8000-000000000006',
        '16000000-0000-4000-8000-000000000006',
        'recipient'
    );

insert into restitution.case_document (
    id,
    case_id,
    source_id,
    document_role
)
values
    (
        '95000000-0000-4000-8000-000000000001',
        '91000000-0000-4000-8000-000000000001',
        '46000000-0000-4000-8000-000000000001',
        'decision_announcement'
    ),
    (
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001',
        '46000000-0000-4000-8000-000000000002',
        'process_account'
    ),
    (
        '95000000-0000-4000-8000-000000000003',
        '91000000-0000-4000-8000-000000000001',
        '46000000-0000-4000-8000-000000000003',
        'handover_record'
    ),
    (
        '95000000-0000-4000-8000-000000000004',
        '91000000-0000-4000-8000-000000000001',
        '46000000-0000-4000-8000-000000000004',
        'handover_record'
    );

insert into restitution.action_document (
    id,
    action_id,
    document_id,
    case_id
)
values
    (
        '96000000-0000-4000-8000-000000000001',
        '93000000-0000-4000-8000-000000000003',
        '95000000-0000-4000-8000-000000000001',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000002',
        '93000000-0000-4000-8000-000000000004',
        '95000000-0000-4000-8000-000000000001',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000003',
        '93000000-0000-4000-8000-000000000001',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000004',
        '93000000-0000-4000-8000-000000000002',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000005',
        '93000000-0000-4000-8000-000000000003',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000006',
        '93000000-0000-4000-8000-000000000004',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000007',
        '93000000-0000-4000-8000-000000000005',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000008',
        '93000000-0000-4000-8000-000000000006',
        '95000000-0000-4000-8000-000000000002',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000009',
        '93000000-0000-4000-8000-000000000005',
        '95000000-0000-4000-8000-000000000003',
        '91000000-0000-4000-8000-000000000001'
    ),
    (
        '96000000-0000-4000-8000-000000000010',
        '93000000-0000-4000-8000-000000000006',
        '95000000-0000-4000-8000-000000000004',
        '91000000-0000-4000-8000-000000000001'
    );

commit;
