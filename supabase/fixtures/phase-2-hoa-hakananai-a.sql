-- Deterministic local/test fixture for Phase 2 case 07: Hoa Hakananaiʻa provenance.
-- Uses deterministic UUIDs in range 13/23/33/43/53/63/73/83.
-- Reuses the Phase 1 Hoa Hakananaiʻa item, British Museum, London, catalogue and Paula note.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if not exists (
        select 1 from entities.entity
        where id = '30000000-0000-4000-8000-000000000001'::uuid
          and entity_type = 'item'
    ) then
        raise exception 'Phase 2 Hoa Hakananaiʻa fixture requires the Phase 1 Hoa item.';
    end if;

    if not exists (
        select 1 from entities.entity
        where id = '10000000-0000-4000-8000-000000000002'::uuid
          and entity_type = 'agent'
    ) then
        raise exception 'Phase 2 Hoa Hakananaiʻa fixture requires the Phase 1 British Museum agent.';
    end if;

    if not exists (
        select 1 from entities.entity
        where id = '40000000-0000-4000-8000-000000000001'::uuid
          and entity_type = 'source'
    ) then
        raise exception 'Phase 2 Hoa Hakananaiʻa fixture requires the Phase 1 British Museum catalogue source.';
    end if;

    if not exists (
        select 1 from entities.entity
        where id = '40000000-0000-4000-8000-000000000002'::uuid
          and entity_type = 'source'
    ) then
        raise exception 'Phase 2 Hoa Hakananaiʻa fixture requires the Phase 1 Paula Rossetti note.';
    end if;
end;
$$;

-- Reserved Phase 2 Hoa fixture UUID ranges are replaced atomically on each load.
delete from knowledge.claim_evidence
where id >= '63000000-0000-4000-8000-000000000000'::uuid
  and id <  '63000000-0000-4000-8000-000000000200'::uuid;

delete from knowledge.claim
where id >= '53000000-0000-4000-8000-000000000000'::uuid
  and id <  '53000000-0000-4000-8000-000000000200'::uuid;

delete from entities.external_identifier
where id >= '73000000-0000-4000-8000-000000000000'::uuid
  and id <  '73000000-0000-4000-8000-000000000100'::uuid;

delete from provenance.event
where id >= '83000000-0000-4000-8000-000000000000'::uuid
  and id <  '83000000-0000-4000-8000-000000000100'::uuid;

delete from entities.item
where id = '33000000-0000-4000-8000-000000000001'::uuid;

delete from entities.agent
where id >= '13000000-0000-4000-8000-000000000000'::uuid
  and id <  '13000000-0000-4000-8000-000000000100'::uuid;

delete from entities.place
where id >= '23000000-0000-4000-8000-000000000000'::uuid
  and id <  '23000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '43000000-0000-4000-8000-000000000000'::uuid
  and id <  '43000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
    '13000000-0000-4000-8000-000000000001'::uuid,
    '13000000-0000-4000-8000-000000000002'::uuid,
    '13000000-0000-4000-8000-000000000003'::uuid,
    '13000000-0000-4000-8000-000000000004'::uuid,
    '13000000-0000-4000-8000-000000000005'::uuid,
    '23000000-0000-4000-8000-000000000001'::uuid,
    '23000000-0000-4000-8000-000000000002'::uuid,
    '23000000-0000-4000-8000-000000000003'::uuid,
    '33000000-0000-4000-8000-000000000001'::uuid,
    '83000000-0000-4000-8000-000000000001'::uuid,
    '83000000-0000-4000-8000-000000000002'::uuid,
    '83000000-0000-4000-8000-000000000003'::uuid,
    '83000000-0000-4000-8000-000000000004'::uuid
);

insert into entities.entity (id, entity_type)
values
    ('13000000-0000-4000-8000-000000000001', 'agent'),
    ('13000000-0000-4000-8000-000000000002', 'agent'),
    ('13000000-0000-4000-8000-000000000003', 'agent'),
    ('13000000-0000-4000-8000-000000000004', 'agent'),
    ('13000000-0000-4000-8000-000000000005', 'agent'),
    ('23000000-0000-4000-8000-000000000001', 'place'),
    ('23000000-0000-4000-8000-000000000002', 'place'),
    ('23000000-0000-4000-8000-000000000003', 'place'),
    ('33000000-0000-4000-8000-000000000001', 'item'),
    ('83000000-0000-4000-8000-000000000001', 'event'),
    ('83000000-0000-4000-8000-000000000002', 'event'),
    ('83000000-0000-4000-8000-000000000003', 'event'),
    ('83000000-0000-4000-8000-000000000004', 'event');

insert into entities.agent (id, agent_kind) values
    ('13000000-0000-4000-8000-000000000001', 'organisation'),
    ('13000000-0000-4000-8000-000000000002', 'person'),
    ('13000000-0000-4000-8000-000000000003', 'organisation'),
    ('13000000-0000-4000-8000-000000000004', 'person'),
    ('13000000-0000-4000-8000-000000000005', 'community');

insert into entities.place (id, place_kind) values
    ('23000000-0000-4000-8000-000000000001', 'site'),
    ('23000000-0000-4000-8000-000000000002', 'island'),
    ('23000000-0000-4000-8000-000000000003', 'country');

insert into entities.item (id, item_kind)
values ('33000000-0000-4000-8000-000000000001', 'vessel');

insert into provenance.event (id, event_kind) values
    ('83000000-0000-4000-8000-000000000001', 'relocation'),
    ('83000000-0000-4000-8000-000000000002', 'relocation'),
    ('83000000-0000-4000-8000-000000000003', 'transfer'),
    ('83000000-0000-4000-8000-000000000004', 'transfer');

insert into knowledge.claim (id, subject_id, predicate, object_entity_id, literal_value, asserted_by_agent_id, notes)
values

    -- Display names for Case 07 agents, places and vessel.
    ('53000000-0000-4000-8000-000000000100', '13000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"HMS Topaze expedition"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000101', '13000000-0000-4000-8000-000000000002', 'has_name', null, '{"type":"text","value":"Richard Ashmore Powell"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000102', '13000000-0000-4000-8000-000000000003', 'has_name', null, '{"type":"text","value":"British Admiralty"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000103', '13000000-0000-4000-8000-000000000004', 'has_name', null, '{"type":"text","value":"Queen Victoria"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000104', '13000000-0000-4000-8000-000000000005', 'has_name', null, '{"type":"text","value":"Council of Elders"}'::jsonb, '10000000-0000-4000-8000-000000000001', null),
    ('53000000-0000-4000-8000-000000000105', '23000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"Orongo"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000106', '23000000-0000-4000-8000-000000000002', 'has_name', null, '{"type":"text","value":"Rapa Nui"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000107', '23000000-0000-4000-8000-000000000003', 'has_name', null, '{"type":"text","value":"England"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000108', '33000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"HMS Topaze"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),

    -- Vessel command relationship (outside events).
    ('53000000-0000-4000-8000-000000000010', '33000000-0000-4000-8000-000000000001', 'commanded_by', '13000000-0000-4000-8000-000000000002', null, '10000000-0000-4000-8000-000000000002', null),

    -- Event 1: removal at Orongo, 1868.
    ('53000000-0000-4000-8000-000000000020', '83000000-0000-4000-8000-000000000001', 'moved_item', '30000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000021', '83000000-0000-4000-8000-000000000001', 'moved_from', '23000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000022', '83000000-0000-4000-8000-000000000001', 'occurred_at', '23000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000023', '83000000-0000-4000-8000-000000000001', 'carried_out_by', '13000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000024', '83000000-0000-4000-8000-000000000001', 'occurred_during', null, '{"type":"date_interval","earliest":"1868","latest":"1868","precision":"year","interpretation":"exact","verbatim":"1868"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000025', '83000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"removed from original location","language":"en"}'::jsonb, '10000000-0000-4000-8000-000000000002', 'BM catalogue wording'),
    ('53000000-0000-4000-8000-000000000026', '83000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"collected","language":"en"}'::jsonb, '10000000-0000-4000-8000-000000000002', 'BM catalogue wording'),
    ('53000000-0000-4000-8000-000000000027', '83000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"taken from Rapa Nui","language":"en"}'::jsonb, '13000000-0000-4000-8000-000000000005', 'Community position reported indirectly'),

    -- Event 2: transport from Rapa Nui to England via HMS Topaze.
    ('53000000-0000-4000-8000-000000000030', '83000000-0000-4000-8000-000000000002', 'moved_item', '30000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000031', '83000000-0000-4000-8000-000000000002', 'moved_from', '23000000-0000-4000-8000-000000000002', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000032', '83000000-0000-4000-8000-000000000002', 'moved_to', '23000000-0000-4000-8000-000000000003', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000033', '83000000-0000-4000-8000-000000000002', 'carried_out_by', '13000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000034', '83000000-0000-4000-8000-000000000002', 'moved_via', '33000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000035', '83000000-0000-4000-8000-000000000002', 'occurred_during', null, '{"type":"date_interval","earliest":"1868","latest":"1869","precision":"year","interpretation":"range","verbatim":"1868–1869"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),

    -- Event 3: Admiralty presentation or offer to Queen Victoria.
    ('53000000-0000-4000-8000-000000000040', '83000000-0000-4000-8000-000000000003', 'transferred_item', '30000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000041', '83000000-0000-4000-8000-000000000003', 'carried_out_by', '13000000-0000-4000-8000-000000000003', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000042', '83000000-0000-4000-8000-000000000003', 'transferred_to', '13000000-0000-4000-8000-000000000004', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000043', '83000000-0000-4000-8000-000000000003', 'occurred_during', null, '{"type":"date_interval","earliest":"1869","latest":"1869","precision":"year","interpretation":"exact","verbatim":"1869"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000044', '83000000-0000-4000-8000-000000000003', 'described_as', null, '{"type":"text","value":"presented","language":"en"}'::jsonb, '10000000-0000-4000-8000-000000000002', 'BM catalogue wording'),

    -- Event 4: Queen Victoria transfer to the British Museum.
    ('53000000-0000-4000-8000-000000000050', '83000000-0000-4000-8000-000000000004', 'transferred_item', '30000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000051', '83000000-0000-4000-8000-000000000004', 'transferred_from', '13000000-0000-4000-8000-000000000004', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000052', '83000000-0000-4000-8000-000000000004', 'transferred_to', '10000000-0000-4000-8000-000000000002', null, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000053', '83000000-0000-4000-8000-000000000004', 'occurred_during', null, '{"type":"date_interval","earliest":"1869","latest":"1869","precision":"year","interpretation":"exact","verbatim":"1869"}'::jsonb, '10000000-0000-4000-8000-000000000002', null),
    ('53000000-0000-4000-8000-000000000054', '83000000-0000-4000-8000-000000000004', 'described_as', null, '{"type":"text","value":"donated","language":"en"}'::jsonb, '10000000-0000-4000-8000-000000000002', 'BM catalogue wording');

-- Catalogue-backed evidence for vessel command and BM event claims.
insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
values
    ('63000000-0000-4000-8000-000000000010', '53000000-0000-4000-8000-000000000010', '40000000-0000-4000-8000-000000000001', 'supports', 'Provenance > Field collector / captain', 'Captain Richard Ashmore Powell'),
    ('63000000-0000-4000-8000-000000000025', '53000000-0000-4000-8000-000000000025', '40000000-0000-4000-8000-000000000001', 'supports', 'Acquisition notes', 'removed from original location'),
    ('63000000-0000-4000-8000-000000000026', '53000000-0000-4000-8000-000000000026', '40000000-0000-4000-8000-000000000001', 'supports', 'Acquisition notes', 'collected'),
    ('63000000-0000-4000-8000-000000000027', '53000000-0000-4000-8000-000000000027', '40000000-0000-4000-8000-000000000002', 'mentions', 'Comentarios Paula Rossetti', 'taken from Rapa Nui'),
    ('63000000-0000-4000-8000-000000000044', '53000000-0000-4000-8000-000000000044', '40000000-0000-4000-8000-000000000001', 'supports', 'Acquisition notes', 'presented'),
    ('63000000-0000-4000-8000-000000000054', '53000000-0000-4000-8000-000000000054', '40000000-0000-4000-8000-000000000001', 'supports', 'Acquisition notes', 'donated');

insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
select
    ('63000000-0000-4000-8000-' || right(claim.id::text, 12))::uuid,
    claim.id,
    '40000000-0000-4000-8000-000000000001'::uuid,
    'supports',
    case
        when claim.subject_id = '83000000-0000-4000-8000-000000000001'::uuid
            then 'Provenance > Removal at Orongo'
        when claim.subject_id = '83000000-0000-4000-8000-000000000002'::uuid
            then 'Provenance > Transport to England'
        when claim.subject_id = '83000000-0000-4000-8000-000000000003'::uuid
            then 'Provenance > Admiralty presentation'
        when claim.subject_id = '83000000-0000-4000-8000-000000000004'::uuid
            then 'Provenance > Transfer to the British Museum'
        else 'Provenance'
    end,
    case
        when claim.subject_id = '83000000-0000-4000-8000-000000000001'::uuid
            then 'found in a stone house at Orongo during the 1868 visit of HMS Topaze'
        when claim.subject_id = '83000000-0000-4000-8000-000000000002'::uuid
            then 'HMS Topaze returned to England in 1869 after the 1868 Rapa Nui visit'
        when claim.subject_id = '83000000-0000-4000-8000-000000000003'::uuid
            then 'offered or presented to Queen Victoria by the Admiralty'
        when claim.subject_id = '83000000-0000-4000-8000-000000000004'::uuid
            then 'Queen Victoria donated the statue to the British Museum in 1869'
        else null
    end
from knowledge.claim as claim
where claim.subject_id in (
    '83000000-0000-4000-8000-000000000001'::uuid,
    '83000000-0000-4000-8000-000000000002'::uuid,
    '83000000-0000-4000-8000-000000000003'::uuid,
    '83000000-0000-4000-8000-000000000004'::uuid
)
  and claim.predicate <> 'described_as';

insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
select
    ('63000000-0000-4000-8000-' || right(claim.id::text, 12))::uuid,
    claim.id,
    case
        when claim.subject_id = '13000000-0000-4000-8000-000000000005'::uuid
            then '40000000-0000-4000-8000-000000000002'::uuid
        else '40000000-0000-4000-8000-000000000001'::uuid
    end,
    'supports',
    'Display name',
    claim.literal_value ->> 'value'
from knowledge.claim as claim
where claim.id in (
    '53000000-0000-4000-8000-000000000100'::uuid,
    '53000000-0000-4000-8000-000000000101'::uuid,
    '53000000-0000-4000-8000-000000000102'::uuid,
    '53000000-0000-4000-8000-000000000103'::uuid,
    '53000000-0000-4000-8000-000000000104'::uuid,
    '53000000-0000-4000-8000-000000000105'::uuid,
    '53000000-0000-4000-8000-000000000106'::uuid,
    '53000000-0000-4000-8000-000000000107'::uuid,
    '53000000-0000-4000-8000-000000000108'::uuid
);

commit;
