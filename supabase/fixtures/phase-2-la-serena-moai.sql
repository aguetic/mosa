-- Deterministic local/test fixture for Phase 2 case 08: La Serena moai provenance.
-- Uses deterministic UUIDs in range 14/24/34/44/54/64/74/84.
-- Depends on the Phase 1 fixture for Paula Rossetti.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if not exists (
        select 1 from entities.entity
        where id = '10000000-0000-4000-8000-000000000001'::uuid
          and entity_type = 'agent'
    ) then
        raise exception 'Phase 2 La Serena fixture requires the Phase 1 fixture to be loaded first.';
    end if;
end;
$$;

-- Reserved Phase 2 La Serena fixture UUID ranges are replaced atomically on each load.
delete from knowledge.claim_evidence
where id >= '64000000-0000-4000-8000-000000000000'::uuid
  and id <  '64000000-0000-4000-8000-000000000200'::uuid;

delete from knowledge.claim
where id >= '54000000-0000-4000-8000-000000000000'::uuid
  and id <  '54000000-0000-4000-8000-000000000200'::uuid;

delete from entities.external_identifier
where id >= '74000000-0000-4000-8000-000000000000'::uuid
  and id <  '74000000-0000-4000-8000-000000000100'::uuid;

delete from provenance.event
where id >= '84000000-0000-4000-8000-000000000000'::uuid
  and id <  '84000000-0000-4000-8000-000000000100'::uuid;

delete from entities.item
where id = '34000000-0000-4000-8000-000000000001'::uuid;

delete from entities.agent
where id >= '14000000-0000-4000-8000-000000000000'::uuid
  and id <  '14000000-0000-4000-8000-000000000100'::uuid;

delete from entities.place
where id >= '24000000-0000-4000-8000-000000000000'::uuid
  and id <  '24000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '44000000-0000-4000-8000-000000000000'::uuid
  and id <  '44000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
    '14000000-0000-4000-8000-000000000001'::uuid,
    '24000000-0000-4000-8000-000000000001'::uuid,
    '24000000-0000-4000-8000-000000000002'::uuid,
    '34000000-0000-4000-8000-000000000001'::uuid,
    '44000000-0000-4000-8000-000000000001'::uuid,
    '84000000-0000-4000-8000-000000000001'::uuid
);

insert into entities.entity (id, entity_type)
values
    ('14000000-0000-4000-8000-000000000001', 'agent'),
    ('24000000-0000-4000-8000-000000000001', 'place'),
    ('24000000-0000-4000-8000-000000000002', 'place'),
    ('34000000-0000-4000-8000-000000000001', 'item'),
    ('44000000-0000-4000-8000-000000000001', 'source'),
    ('84000000-0000-4000-8000-000000000001', 'event');

insert into entities.agent (id, agent_kind)
values ('14000000-0000-4000-8000-000000000001', 'organisation');

insert into entities.place (id, place_kind) values
    ('24000000-0000-4000-8000-000000000001', 'island'),
    ('24000000-0000-4000-8000-000000000002', 'city');

insert into entities.item (id, item_kind)
values ('34000000-0000-4000-8000-000000000001', 'artefact');

insert into entities.source (id, source_kind, reference)
values (
    '44000000-0000-4000-8000-000000000001',
    'research_note',
    'docs/source-material/La Serena moai'
);

insert into provenance.event (id, event_kind)
values ('84000000-0000-4000-8000-000000000001', 'relocation');

insert into knowledge.claim (id, subject_id, predicate, object_entity_id, literal_value, asserted_by_agent_id, notes)
values

    -- Display names.
    ('54000000-0000-4000-8000-000000000100', '14000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"Museo Arqueológico de La Serena"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000101', '24000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"Rapa Nui"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000102', '24000000-0000-4000-8000-000000000002', 'has_name', null, '{"type":"text","value":"La Serena"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000103', '44000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"Paula Rossetti''s note"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),

    -- Source and item identity.
    ('54000000-0000-4000-8000-000000000001', '44000000-0000-4000-8000-000000000001', 'refers_to', '34000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000002', '44000000-0000-4000-8000-000000000001', 'authored_by', '10000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000003', '34000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"La Serena moai","language":"en"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000004', '34000000-0000-4000-8000-000000000001', 'classified_as', null, '{"type":"text","value":"moai","language":"rap"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),

    -- Current-state item claims (not provenance events).
    ('54000000-0000-4000-8000-000000000010', '34000000-0000-4000-8000-000000000001', 'held_by', '14000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000011', '34000000-0000-4000-8000-000000000001', 'located_at', '24000000-0000-4000-8000-000000000002', null, '10000000-0000-4000-8000-000000000001', null),

    -- Provisional 1952 movement: physical claim only; gift characterisation remains described_as.
    ('54000000-0000-4000-8000-000000000020', '84000000-0000-4000-8000-000000000001', 'moved_item', '34000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000021', '84000000-0000-4000-8000-000000000001', 'occurred_during', null, '{"type":"date_interval","earliest":"1952","latest":"1952","precision":"year","interpretation":"exact","verbatim":"1952"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('54000000-0000-4000-8000-000000000022', '84000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"se dice que fue un regalo del pueblo Rapa Nui","language":"es"}'::jsonb, null, 'Hearsay characterisation; underlying speaker not recorded');

-- Paula-note evidence. Gift characterisation uses mentions; structural claims use supports.
insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
values
    (
        '64000000-0000-4000-8000-000000000020',
        '54000000-0000-4000-8000-000000000020',
        '44000000-0000-4000-8000-000000000001',
        'supports',
        'Provenance',
        'fue llevado en 1952'
    ),
    (
        '64000000-0000-4000-8000-000000000021',
        '54000000-0000-4000-8000-000000000021',
        '44000000-0000-4000-8000-000000000001',
        'supports',
        'Provenance',
        '1952'
    ),
    (
        '64000000-0000-4000-8000-000000000022',
        '54000000-0000-4000-8000-000000000022',
        '44000000-0000-4000-8000-000000000001',
        'mentions',
        'Provenance',
        'se dice que fue un regalo del pueblo Rapa Nui'
    ),
    (
        '64000000-0000-4000-8000-000000000010',
        '54000000-0000-4000-8000-000000000010',
        '44000000-0000-4000-8000-000000000001',
        'supports',
        'Current location',
        'Museo Arqueológico de La Serena'
    ),
    (
        '64000000-0000-4000-8000-000000000011',
        '54000000-0000-4000-8000-000000000011',
        '44000000-0000-4000-8000-000000000001',
        'supports',
        'Current location',
        'La Serena'
    );

commit;
