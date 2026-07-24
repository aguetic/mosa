-- Deterministic local/test fixture for Phase 2 case 09:
-- British Museum Ama Af1898,0115.30.
--
-- Four separate events: February 1897 palace removal; reported movement to
-- Britain and placement at the Foreign Office; provisional 1897 temporary
-- loan; 1898 gift. "Looted", "temporary loan" and "gift" remain attributed
-- source wording. Collection-level acquisition notes and "spoils of war"
-- wording use provides_context rather than supports. Display order comes
-- from structured dates; the fixture does not store preceded_by chains.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if not exists (
        select 1
        from entities.agent
        where id = '10000000-0000-4000-8000-000000000002'::uuid
    ) then
        raise exception
            'Case 09 requires the existing British Museum agent.';
    end if;

    if exists (
        select 1
        from entities.external_identifier
        where namespace = 'british-museum'
          and value = 'Af1898,0115.30'
          and id <> '75000000-0000-4000-8000-000000000001'::uuid
    ) then
        raise exception
            'British Museum identifier Af1898,0115.30 already exists under a non-fixture UUID.';
    end if;
end;
$$;

-- Make the fixture repeatable within its reserved Case 09 UUID ranges.
delete from knowledge.claim_evidence
where id >= '65000000-0000-4000-8000-000000000000'::uuid
  and id <  '65000000-0000-4000-8000-000000000100'::uuid;

delete from knowledge.claim
where id >= '55000000-0000-4000-8000-000000000000'::uuid
  and id <  '55000000-0000-4000-8000-000000000100'::uuid;

delete from entities.external_identifier
where id >= '75000000-0000-4000-8000-000000000000'::uuid
  and id <  '75000000-0000-4000-8000-000000000100'::uuid;

delete from provenance.event
where id >= '85000000-0000-4000-8000-000000000000'::uuid
  and id <  '85000000-0000-4000-8000-000000000100'::uuid;

delete from entities.item
where id = '35000000-0000-4000-8000-000000000001'::uuid;

delete from entities.agent
where id >= '15000000-0000-4000-8000-000000000000'::uuid
  and id <  '15000000-0000-4000-8000-000000000100'::uuid;

delete from entities.place
where id >= '25000000-0000-4000-8000-000000000000'::uuid
  and id <  '25000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '45000000-0000-4000-8000-000000000000'::uuid
  and id <  '45000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
    '15000000-0000-4000-8000-000000000001'::uuid,
    '15000000-0000-4000-8000-000000000002'::uuid,
    '15000000-0000-4000-8000-000000000003'::uuid,
    '15000000-0000-4000-8000-000000000004'::uuid,
    '25000000-0000-4000-8000-000000000001'::uuid,
    '25000000-0000-4000-8000-000000000002'::uuid,
    '25000000-0000-4000-8000-000000000003'::uuid,
    '35000000-0000-4000-8000-000000000001'::uuid,
    '45000000-0000-4000-8000-000000000001'::uuid,
    '45000000-0000-4000-8000-000000000002'::uuid,
    '45000000-0000-4000-8000-000000000003'::uuid,
    '85000000-0000-4000-8000-000000000001'::uuid,
    '85000000-0000-4000-8000-000000000002'::uuid,
    '85000000-0000-4000-8000-000000000003'::uuid,
    '85000000-0000-4000-8000-000000000004'::uuid
);

insert into entities.entity (id, entity_type)
values
    ('15000000-0000-4000-8000-000000000001', 'agent'),
    ('15000000-0000-4000-8000-000000000002', 'agent'),
    ('15000000-0000-4000-8000-000000000003', 'agent'),
    ('15000000-0000-4000-8000-000000000004', 'agent'),
    ('25000000-0000-4000-8000-000000000001', 'place'),
    ('25000000-0000-4000-8000-000000000002', 'place'),
    ('25000000-0000-4000-8000-000000000003', 'place'),
    ('35000000-0000-4000-8000-000000000001', 'item'),
    ('45000000-0000-4000-8000-000000000001', 'source'),
    ('45000000-0000-4000-8000-000000000002', 'source'),
    ('45000000-0000-4000-8000-000000000003', 'source'),
    ('85000000-0000-4000-8000-000000000001', 'event'),
    ('85000000-0000-4000-8000-000000000002', 'event'),
    ('85000000-0000-4000-8000-000000000003', 'event'),
    ('85000000-0000-4000-8000-000000000004', 'event');

insert into entities.agent (id, agent_kind)
values
    (
        '15000000-0000-4000-8000-000000000001',
        'expedition'
    ),
    (
        '15000000-0000-4000-8000-000000000002',
        'organisation'
    ),
    (
        '15000000-0000-4000-8000-000000000003',
        'office'
    ),
    (
        '15000000-0000-4000-8000-000000000004',
        'research_project'
    );

insert into entities.place (id, place_kind)
values
    (
        '25000000-0000-4000-8000-000000000001',
        'city'
    ),
    (
        '25000000-0000-4000-8000-000000000002',
        'palace'
    ),
    (
        '25000000-0000-4000-8000-000000000003',
        'country'
    );

insert into entities.item (id, item_kind)
values (
    '35000000-0000-4000-8000-000000000001',
    'artefact'
);

insert into entities.source (
    id,
    source_kind,
    reference,
    retrieved_at
)
values
    (
        '45000000-0000-4000-8000-000000000001',
        'institutional_record',
        'https://www.britishmuseum.org/collection/object/E_Af1898-0115-30',
        null
    ),
    (
        '45000000-0000-4000-8000-000000000002',
        'institutional_webpage',
        'https://www.britishmuseum.org/about-us/british-museum-story/contested-objects-collection/benin-bronzes',
        null
    ),
    (
        '45000000-0000-4000-8000-000000000003',
        'research_database',
        'https://digitalbenin.org/catalogue',
        null
    );

insert into provenance.event (id, event_kind)
values
    (
        '85000000-0000-4000-8000-000000000001',
        'relocation'
    ),
    (
        '85000000-0000-4000-8000-000000000002',
        'relocation'
    ),
    (
        '85000000-0000-4000-8000-000000000003',
        'transfer'
    ),
    (
        '85000000-0000-4000-8000-000000000004',
        'transfer'
    );

insert into entities.external_identifier (
    id,
    entity_id,
    namespace,
    value,
    source_id
)
values (
    '75000000-0000-4000-8000-000000000001',
    '35000000-0000-4000-8000-000000000001',
    'british-museum',
    'Af1898,0115.30',
    '45000000-0000-4000-8000-000000000001'
);

-- Display labels and source relationships.
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
        '55000000-0000-4000-8000-000000000001',
        '35000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value',
            'Plaque depicting an Oba with mudfish legs and two leopards',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000002',
        '35000000-0000-4000-8000-000000000001',
        'classified_as',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Ama',
            'language', 'bin'
        ),
        '15000000-0000-4000-8000-000000000004'
    ),
    (
        '55000000-0000-4000-8000-000000000003',
        '35000000-0000-4000-8000-000000000001',
        'classified_as',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'relief plaque',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000004',
        '35000000-0000-4000-8000-000000000001',
        'made_of',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'brass',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000006',
        '35000000-0000-4000-8000-000000000001',
        'made_during',
        null,
        jsonb_build_object(
            'type', 'date_interval',
            'earliest', '1501',
            'latest', '1700',
            'precision', 'century',
            'interpretation', 'approximate_range',
            'verbatim', '16thC–17thC'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000008',
        '45000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'British Museum collection record: Af1898,0115.30',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000011',
        '45000000-0000-4000-8000-000000000002',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'British Museum account of the Benin Bronzes',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000014',
        '15000000-0000-4000-8000-000000000004',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Digital Benin',
            'language', 'en'
        ),
        '15000000-0000-4000-8000-000000000004'
    ),
    (
        '55000000-0000-4000-8000-000000000015',
        '45000000-0000-4000-8000-000000000003',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Digital Benin catalogue record: Af1898,0115.30',
            'language', 'en'
        ),
        '15000000-0000-4000-8000-000000000004'
    ),
    (
        '55000000-0000-4000-8000-000000000018',
        '15000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'British expeditionary force to Benin City',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000019',
        '15000000-0000-4000-8000-000000000002',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'British Foreign Office',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000020',
        '15000000-0000-4000-8000-000000000003',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Secretary of State for Foreign Affairs',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000021',
        '25000000-0000-4000-8000-000000000001',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Benin City',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000022',
        '25000000-0000-4000-8000-000000000002',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Oba''s palace, Benin City',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000023',
        '25000000-0000-4000-8000-000000000003',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'United Kingdom',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    asserted_by_agent_id
)
values
    (
        '55000000-0000-4000-8000-000000000005',
        '35000000-0000-4000-8000-000000000001',
        'made_at',
        '25000000-0000-4000-8000-000000000001',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000007',
        '35000000-0000-4000-8000-000000000001',
        'held_by',
        '10000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000009',
        '45000000-0000-4000-8000-000000000001',
        'published_by',
        '10000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000010',
        '45000000-0000-4000-8000-000000000001',
        'refers_to',
        '35000000-0000-4000-8000-000000000001',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000012',
        '45000000-0000-4000-8000-000000000002',
        'published_by',
        '10000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000013',
        '45000000-0000-4000-8000-000000000002',
        'refers_to',
        '35000000-0000-4000-8000-000000000001',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000016',
        '45000000-0000-4000-8000-000000000003',
        'published_by',
        '15000000-0000-4000-8000-000000000004',
        '15000000-0000-4000-8000-000000000004'
    ),
    (
        '55000000-0000-4000-8000-000000000017',
        '45000000-0000-4000-8000-000000000003',
        'refers_to',
        '35000000-0000-4000-8000-000000000001',
        '15000000-0000-4000-8000-000000000004'
    );

-- Event 1: February 1897 palace removal.
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
        '55000000-0000-4000-8000-000000000030',
        '85000000-0000-4000-8000-000000000001',
        'moved_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000031',
        '85000000-0000-4000-8000-000000000001',
        'moved_from',
        '25000000-0000-4000-8000-000000000002',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000032',
        '85000000-0000-4000-8000-000000000001',
        'carried_out_by',
        '15000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000033',
        '85000000-0000-4000-8000-000000000001',
        'occurred_during',
        null,
        jsonb_build_object(
            'type', 'date_interval',
            'earliest', '1897-02',
            'latest', '1897-02',
            'precision', 'month',
            'interpretation', 'exact',
            'verbatim', 'February 1897'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000034',
        '85000000-0000-4000-8000-000000000001',
        'described_as',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'looted by British forces',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

-- Event 2: reported movement to Britain and placement at the Foreign Office.
-- Both moved_item and transferred_item are deliberate: the source reports
-- sending to Britain and placing the plaques at the Foreign Office as one
-- episode. Structural claims below are group-scoped unless individually
-- established.
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
        '55000000-0000-4000-8000-000000000040',
        '85000000-0000-4000-8000-000000000002',
        'moved_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000041',
        '85000000-0000-4000-8000-000000000002',
        'transferred_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000042',
        '85000000-0000-4000-8000-000000000002',
        'moved_from',
        '25000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000043',
        '85000000-0000-4000-8000-000000000002',
        'moved_to',
        '25000000-0000-4000-8000-000000000003',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000044',
        '85000000-0000-4000-8000-000000000002',
        'transferred_to',
        '15000000-0000-4000-8000-000000000002',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000045',
        '85000000-0000-4000-8000-000000000002',
        'occurred_during',
        null,
        jsonb_build_object(
            'type', 'date_interval',
            'earliest', '1897',
            'latest', '1897',
            'precision', 'year',
            'interpretation', 'exact',
            'verbatim', '1897'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

-- Event 3: provisional 1897 temporary loan. Retained because the object
-- record associates this registration with the plaque group later gifted to
-- the Museum, but membership in the 1897 loan is not individually attested.
-- Evidence for these claims is therefore provides_context.
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
        '55000000-0000-4000-8000-000000000050',
        '85000000-0000-4000-8000-000000000003',
        'moved_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000051',
        '85000000-0000-4000-8000-000000000003',
        'transferred_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000052',
        '85000000-0000-4000-8000-000000000003',
        'transferred_from',
        '15000000-0000-4000-8000-000000000002',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000053',
        '85000000-0000-4000-8000-000000000003',
        'transferred_to',
        '10000000-0000-4000-8000-000000000002',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000054',
        '85000000-0000-4000-8000-000000000003',
        'occurred_during',
        null,
        jsonb_build_object(
            'type', 'date_interval',
            'earliest', '1897',
            'latest', '1897',
            'precision', 'year',
            'interpretation', 'exact',
            'verbatim', '1897'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000055',
        '85000000-0000-4000-8000-000000000003',
        'described_as',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'temporary loan',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

-- Event 4: 1898 gift to the British Museum. The item was already physically
-- present, so this event intentionally has no moved_item claim. Acquisition
-- name/date on this registration support the gift at object level.
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
        '55000000-0000-4000-8000-000000000060',
        '85000000-0000-4000-8000-000000000004',
        'transferred_item',
        '35000000-0000-4000-8000-000000000001',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000061',
        '85000000-0000-4000-8000-000000000004',
        'transferred_from',
        '15000000-0000-4000-8000-000000000003',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000062',
        '85000000-0000-4000-8000-000000000004',
        'transferred_to',
        '10000000-0000-4000-8000-000000000002',
        null,
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000063',
        '85000000-0000-4000-8000-000000000004',
        'occurred_during',
        null,
        jsonb_build_object(
            'type', 'date_interval',
            'earliest', '1898',
            'latest', '1898',
            'precision', 'year',
            'interpretation', 'exact',
            'verbatim', '1898'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '55000000-0000-4000-8000-000000000064',
        '85000000-0000-4000-8000-000000000004',
        'described_as',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'gift',
            'language', 'en'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

-- Evidence for item/source claims.
insert into knowledge.claim_evidence (
    id,
    claim_id,
    source_id,
    relationship,
    locator,
    excerpt,
    notes
)
values
    (
        '65000000-0000-4000-8000-000000000001',
        '55000000-0000-4000-8000-000000000001',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Description',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000002',
        '55000000-0000-4000-8000-000000000002',
        '45000000-0000-4000-8000-000000000003',
        'supports',
        'Registration Number Af1898,0115.30 > Edo designation',
        'Ama',
        null
    ),
    (
        '65000000-0000-4000-8000-000000000003',
        '55000000-0000-4000-8000-000000000003',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Object Type and Description',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000004',
        '55000000-0000-4000-8000-000000000004',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Materials',
        'brass',
        null
    ),
    (
        '65000000-0000-4000-8000-000000000005',
        '55000000-0000-4000-8000-000000000005',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Production place',
        'Made in: Benin City',
        null
    ),
    (
        '65000000-0000-4000-8000-000000000006',
        '55000000-0000-4000-8000-000000000006',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Production date',
        '16thC-17thC',
        null
    ),
    (
        '65000000-0000-4000-8000-000000000007',
        '55000000-0000-4000-8000-000000000007',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Current collection record',
        null,
        'The record establishes current institutional custody but does not identify a storage location.'
    ),
    (
        '65000000-0000-4000-8000-000000000010',
        '55000000-0000-4000-8000-000000000010',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Whole object record',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000013',
        '55000000-0000-4000-8000-000000000013',
        '45000000-0000-4000-8000-000000000002',
        'provides_context',
        'Benin plaque illustrated and discussed in the collection account',
        null,
        'Collection-level context, not an individual object receipt.'
    ),
    (
        '65000000-0000-4000-8000-000000000017',
        '55000000-0000-4000-8000-000000000017',
        '45000000-0000-4000-8000-000000000003',
        'supports',
        'Registration Number Af1898,0115.30',
        null,
        null
    );

-- Evidence for the four provenance events.
-- Object-record association with the 1897 expedition/removal and the 1898
-- acquisition use supports. Group-level acquisition history (sent to Britain,
-- FO placement, temporary loan of 304 plaques) and the contested-objects
-- "spoils of war" wording use provides_context.
insert into knowledge.claim_evidence (
    id,
    claim_id,
    source_id,
    relationship,
    locator,
    excerpt,
    notes
)
values
    (
        '65000000-0000-4000-8000-000000000030',
        '55000000-0000-4000-8000-000000000030',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Associated events and acquisition notes',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000031',
        '55000000-0000-4000-8000-000000000031',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition notes > royal palace',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000032',
        '55000000-0000-4000-8000-000000000032',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition notes > British forces',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000033',
        '55000000-0000-4000-8000-000000000033',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Associated event: British Expedition to Benin City',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000034',
        '55000000-0000-4000-8000-000000000034',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition notes',
        'looted by British forces',
        null
    ),
    (
        '65000000-0000-4000-8000-000000000035',
        '55000000-0000-4000-8000-000000000034',
        '45000000-0000-4000-8000-000000000002',
        'provides_context',
        'How did the objects come to the British Museum?',
        'official "spoils of war"',
        'Collection-level characterisation of objects taken during the occupation.'
    ),
    (
        '65000000-0000-4000-8000-000000000040',
        '55000000-0000-4000-8000-000000000040',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > sent to the UK',
        null,
        'Group-level acquisition history for more than 300 plaques; not an individual shipping receipt for this registration.'
    ),
    (
        '65000000-0000-4000-8000-000000000041',
        '55000000-0000-4000-8000-000000000041',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > placed at the Foreign Office',
        null,
        'Group-level placement at the Foreign Office; no individual Foreign Office number is recorded for this plaque.'
    ),
    (
        '65000000-0000-4000-8000-000000000042',
        '55000000-0000-4000-8000-000000000042',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > sent to the UK',
        null,
        'Group-level origin for the plaque cohort sent to Britain.'
    ),
    (
        '65000000-0000-4000-8000-000000000043',
        '55000000-0000-4000-8000-000000000043',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > sent to the UK',
        null,
        'Group-level destination for the plaque cohort sent to Britain.'
    ),
    (
        '65000000-0000-4000-8000-000000000044',
        '55000000-0000-4000-8000-000000000044',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > placed at the Foreign Office',
        null,
        'Group-level recipient for the plaque cohort placed at the Foreign Office.'
    ),
    (
        '65000000-0000-4000-8000-000000000045',
        '55000000-0000-4000-8000-000000000045',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes',
        null,
        'Year taken from group-level acquisition notes for the plaque cohort.'
    ),
    (
        '65000000-0000-4000-8000-000000000050',
        '55000000-0000-4000-8000-000000000050',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > temporary loan',
        null,
        'Provisional object link: the record describes a temporary loan of 304 plaques, not an individual loan receipt for this registration.'
    ),
    (
        '65000000-0000-4000-8000-000000000051',
        '55000000-0000-4000-8000-000000000051',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > temporary loan',
        null,
        'Provisional object link from group-level temporary-loan wording.'
    ),
    (
        '65000000-0000-4000-8000-000000000052',
        '55000000-0000-4000-8000-000000000052',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > Foreign Office',
        null,
        'Group-level transfer party for the temporary loan of the plaque cohort.'
    ),
    (
        '65000000-0000-4000-8000-000000000053',
        '55000000-0000-4000-8000-000000000053',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > British Museum',
        null,
        'Group-level transfer party for the temporary loan of the plaque cohort.'
    ),
    (
        '65000000-0000-4000-8000-000000000054',
        '55000000-0000-4000-8000-000000000054',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes > summer and autumn 1897',
        null,
        'Year taken from group-level temporary-loan wording.'
    ),
    (
        '65000000-0000-4000-8000-000000000055',
        '55000000-0000-4000-8000-000000000055',
        '45000000-0000-4000-8000-000000000001',
        'provides_context',
        'Acquisition notes',
        'temporary loan',
        'Group-level characterisation of the 1897 loan of 304 plaques.'
    ),
    (
        '65000000-0000-4000-8000-000000000060',
        '55000000-0000-4000-8000-000000000060',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition name and date',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000061',
        '55000000-0000-4000-8000-000000000061',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition name',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000062',
        '55000000-0000-4000-8000-000000000062',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition record',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000063',
        '55000000-0000-4000-8000-000000000063',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition date',
        null,
        null
    ),
    (
        '65000000-0000-4000-8000-000000000064',
        '55000000-0000-4000-8000-000000000064',
        '45000000-0000-4000-8000-000000000001',
        'supports',
        'Acquisition name',
        'gift',
        null
    );

commit;
