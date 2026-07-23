-- Deterministic local/test fixture for Phase 2 case 06: Te Papa moai kavakava provenance.
-- Uses deterministic UUIDs in a new range (12/22/32/42/52/62/72/82).
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
          and working_label = 'Paula Rossetti'
    ) then
        raise exception 'Phase 2 Te Papa fixture requires the Phase 1 fixture to be loaded first.';
    end if;
end;
$$;

-- Reserved Phase 2 Te Papa fixture UUID ranges are replaced atomically on each load.
delete from knowledge.claim_evidence
where id >= '62000000-0000-4000-8000-000000000000'::uuid
  and id <  '62000000-0000-4000-8000-000000000200'::uuid;

delete from knowledge.claim
where id >= '52000000-0000-4000-8000-000000000000'::uuid
  and id <  '52000000-0000-4000-8000-000000000200'::uuid;

delete from entities.external_identifier
where id >= '72000000-0000-4000-8000-000000000000'::uuid
  and id <  '72000000-0000-4000-8000-000000000100'::uuid;

delete from provenance.event
where id >= '82000000-0000-4000-8000-000000000000'::uuid
  and id <  '82000000-0000-4000-8000-000000000100'::uuid;

delete from entities.item
where id = '32000000-0000-4000-8000-000000000001'::uuid;

delete from entities.agent
where id >= '12000000-0000-4000-8000-000000000000'::uuid
  and id <  '12000000-0000-4000-8000-000000000100'::uuid;

delete from entities.place
where id >= '22000000-0000-4000-8000-000000000000'::uuid
  and id <  '22000000-0000-4000-8000-000000000100'::uuid;

delete from entities.source
where id >= '42000000-0000-4000-8000-000000000000'::uuid
  and id <  '42000000-0000-4000-8000-000000000100'::uuid;

delete from entities.entity
where id in (
    '12000000-0000-4000-8000-000000000001'::uuid,
    '12000000-0000-4000-8000-000000000002'::uuid,
    '12000000-0000-4000-8000-000000000003'::uuid,
    '12000000-0000-4000-8000-000000000004'::uuid,
    '12000000-0000-4000-8000-000000000005'::uuid,
    '22000000-0000-4000-8000-000000000001'::uuid,
    '22000000-0000-4000-8000-000000000002'::uuid,
    '22000000-0000-4000-8000-000000000003'::uuid,
    '32000000-0000-4000-8000-000000000001'::uuid,
    '42000000-0000-4000-8000-000000000001'::uuid,
    '42000000-0000-4000-8000-000000000002'::uuid,
    '82000000-0000-4000-8000-000000000001'::uuid,
    '82000000-0000-4000-8000-000000000002'::uuid,
    '82000000-0000-4000-8000-000000000003'::uuid,
    '82000000-0000-4000-8000-000000000004'::uuid,
    '82000000-0000-4000-8000-000000000005'::uuid
);

insert into entities.entity (id, entity_type, working_label, notes)
values
    ('12000000-0000-4000-8000-000000000001', 'agent', 'F. W. Beechey', null),
    ('12000000-0000-4000-8000-000000000002', 'agent', 'HMS Blossom expedition', null),
    ('12000000-0000-4000-8000-000000000003', 'agent', 'Oldman Collection', null),
    ('12000000-0000-4000-8000-000000000004', 'agent', 'New Zealand Government', null),
    ('12000000-0000-4000-8000-000000000005', 'agent', 'Museum of New Zealand Te Papa Tongarewa', null),
    ('22000000-0000-4000-8000-000000000001', 'place', 'Rapa Nui', null),
    ('22000000-0000-4000-8000-000000000002', 'place', 'England', null),
    ('22000000-0000-4000-8000-000000000003', 'place', 'Wellington', null),
    ('32000000-0000-4000-8000-000000000001', 'item', 'Te Papa moai kavakava', 'Phase 2 case 06; inventory OL000342'),
    ('42000000-0000-4000-8000-000000000001', 'source', 'Te Papa catalogue record', null),
    ('42000000-0000-4000-8000-000000000002', 'source', 'Paula Rossetti note: Te Papa moai kavakava', null),
    ('82000000-0000-4000-8000-000000000001', 'event', 'Possible HMS Blossom collection hypothesis', 'Uncertain collection hypothesis retained as an event anchor'),
    ('82000000-0000-4000-8000-000000000002', 'event', 'Moai kavakava arrival in England', null),
    ('82000000-0000-4000-8000-000000000003', 'event', 'Moai kavakava enters Oldman Collection', null),
    ('82000000-0000-4000-8000-000000000004', 'event', 'Transfer from New Zealand Government to Te Papa', null),
    ('82000000-0000-4000-8000-000000000005', 'event', 'Current Te Papa custody', null);

insert into entities.agent (id, agent_kind) values
    ('12000000-0000-4000-8000-000000000001', 'person'),
    ('12000000-0000-4000-8000-000000000002', 'organisation'),
    ('12000000-0000-4000-8000-000000000003', 'organisation'),
    ('12000000-0000-4000-8000-000000000004', 'organisation'),
    ('12000000-0000-4000-8000-000000000005', 'organisation');

insert into entities.place (id, place_kind) values
    ('22000000-0000-4000-8000-000000000001', 'island'),
    ('22000000-0000-4000-8000-000000000002', 'country'),
    ('22000000-0000-4000-8000-000000000003', 'city');

insert into entities.item (id, item_kind)
values ('32000000-0000-4000-8000-000000000001', 'artefact');

insert into entities.source (id, source_kind, reference) values
    ('42000000-0000-4000-8000-000000000001', 'institutional_record', 'https://collections.tepapa.govt.nz/object/OL000342'),
    ('42000000-0000-4000-8000-000000000002', 'research_note', 'docs/source-material/Te Papa moai kavakava');

insert into provenance.event (id, event_kind) values
    ('82000000-0000-4000-8000-000000000001', 'unknown'),
    ('82000000-0000-4000-8000-000000000002', 'relocation'),
    ('82000000-0000-4000-8000-000000000003', 'unknown'),
    ('82000000-0000-4000-8000-000000000004', 'transfer'),
    ('82000000-0000-4000-8000-000000000005', 'unknown');

insert into entities.external_identifier (id, entity_id, namespace, value, source_id)
values ('72000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000001', 'te-papa-inventory', 'OL000342', '42000000-0000-4000-8000-000000000001');

insert into knowledge.claim (id, subject_id, predicate, object_entity_id, literal_value, asserted_by_agent_id, notes)
values
    -- Sources and item identity.
    ('52000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001', 'refers_to', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000002', '42000000-0000-4000-8000-000000000001', 'published_by', '12000000-0000-4000-8000-000000000005', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000003', '42000000-0000-4000-8000-000000000002', 'refers_to', '32000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('52000000-0000-4000-8000-000000000004', '42000000-0000-4000-8000-000000000002', 'authored_by', '10000000-0000-4000-8000-000000000001', null, '10000000-0000-4000-8000-000000000001', null),
    ('52000000-0000-4000-8000-000000000005', '32000000-0000-4000-8000-000000000001', 'has_name', null, '{"type":"text","value":"moai kavakava","language":"en"}'::jsonb, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000006', '32000000-0000-4000-8000-000000000001', 'classified_as', null, '{"type":"text","value":"moai kavakava","language":"en"}'::jsonb, '12000000-0000-4000-8000-000000000005', null),

    -- Event 1: possible HMS Blossom collection hypothesis.
    ('52000000-0000-4000-8000-000000000020', '82000000-0000-4000-8000-000000000001', 'moved_item', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000021', '82000000-0000-4000-8000-000000000001', 'occurred_at', '22000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000022', '82000000-0000-4000-8000-000000000001', 'carried_out_by', '12000000-0000-4000-8000-000000000002', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000023', '82000000-0000-4000-8000-000000000001', 'involved', '12000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000024', '82000000-0000-4000-8000-000000000001', 'occurred_during', null, '{"type":"date_interval","earliest":"1825","latest":"1825","precision":"year","interpretation":"hypothesis","verbatim":"1825"}'::jsonb, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000025', '82000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"The figure is thought to have been collected during F W Beechey''s expedition in HMS Blossom in 1825","language":"en"}'::jsonb, '12000000-0000-4000-8000-000000000005', 'Hypothesis wording preserved'),
    ('52000000-0000-4000-8000-000000000026', '82000000-0000-4000-8000-000000000001', 'described_as', null, '{"type":"text","value":"The brief and confrontational nature of Beechey''s visit to Rapanui makes this seem unlikely","language":"en"}'::jsonb, '12000000-0000-4000-8000-000000000005', 'Institutional qualification of the hypothesis'),

    -- Event 2: arrival in England. Not linked to Event 1 by preceded_by.
    ('52000000-0000-4000-8000-000000000030', '82000000-0000-4000-8000-000000000002', 'moved_item', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000031', '82000000-0000-4000-8000-000000000002', 'moved_to', '22000000-0000-4000-8000-000000000002', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000032', '82000000-0000-4000-8000-000000000002', 'occurred_during', null, '{"type":"date_interval","earliest":"1828","latest":"1835","precision":"year","interpretation":"alternatives","verbatim":"1828 or 1835","alternatives":["1828","1835"]}'::jsonb, '12000000-0000-4000-8000-000000000005', null),

    -- Event 3: Oldman Collection holding episode.
    ('52000000-0000-4000-8000-000000000040', '82000000-0000-4000-8000-000000000003', 'held_item', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000041', '82000000-0000-4000-8000-000000000003', 'holding_agent', '12000000-0000-4000-8000-000000000003', null, '12000000-0000-4000-8000-000000000005', null),

    -- Event 4: New Zealand Government transfer to Te Papa.
    ('52000000-0000-4000-8000-000000000050', '82000000-0000-4000-8000-000000000004', 'moved_item', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000051', '82000000-0000-4000-8000-000000000004', 'transferred_from', '12000000-0000-4000-8000-000000000004', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000052', '82000000-0000-4000-8000-000000000004', 'transferred_to', '12000000-0000-4000-8000-000000000005', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000053', '82000000-0000-4000-8000-000000000004', 'occurred_during', null, '{"type":"date_interval","earliest":"1992","latest":"1992","precision":"year","interpretation":"exact","verbatim":"1992"}'::jsonb, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000054', '82000000-0000-4000-8000-000000000004', 'described_as', null, '{"type":"text","value":"Gift of the New Zealand Government","language":"en"}'::jsonb, '12000000-0000-4000-8000-000000000005', 'Gift remains descriptive source wording'),

    -- Event 5: current Te Papa custody.
    ('52000000-0000-4000-8000-000000000060', '82000000-0000-4000-8000-000000000005', 'moved_item', '32000000-0000-4000-8000-000000000001', null, '12000000-0000-4000-8000-000000000005', null),
    ('52000000-0000-4000-8000-000000000061', '82000000-0000-4000-8000-000000000005', 'holding_agent', '12000000-0000-4000-8000-000000000005', null, '12000000-0000-4000-8000-000000000005', null);

-- Catalogue-backed event evidence. Excerpts are source wording, never internal event labels.
insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
select
    ('62000000-0000-4000-8000-' || right(claim.id::text, 12))::uuid,
    claim.id,
    '42000000-0000-4000-8000-000000000001'::uuid,
    case when claim.id = '52000000-0000-4000-8000-000000000026'::uuid
         then 'qualifies'
         else 'supports' end,
    case
        when claim.id between '52000000-0000-4000-8000-000000000020'::uuid and '52000000-0000-4000-8000-000000000025'::uuid
            then 'Provenance > HMS Blossom hypothesis'
        when claim.id = '52000000-0000-4000-8000-000000000026'::uuid
            then 'Provenance > HMS Blossom qualification'
        when claim.id between '52000000-0000-4000-8000-000000000030'::uuid and '52000000-0000-4000-8000-000000000032'::uuid
            then 'Provenance > Arrival in England'
        when claim.id between '52000000-0000-4000-8000-000000000040'::uuid and '52000000-0000-4000-8000-000000000041'::uuid
            then 'Provenance > Oldman Collection'
        when claim.id between '52000000-0000-4000-8000-000000000050'::uuid and '52000000-0000-4000-8000-000000000054'::uuid
            then 'Provenance > New Zealand Government transfer'
        when claim.id between '52000000-0000-4000-8000-000000000060'::uuid and '52000000-0000-4000-8000-000000000061'::uuid
            then 'Provenance > Current custody'
        else 'Provenance'
    end,
    case
        when claim.id between '52000000-0000-4000-8000-000000000020'::uuid and '52000000-0000-4000-8000-000000000025'::uuid
            then 'The figure is thought to have been collected during F W Beechey''s expedition in HMS Blossom in 1825'
        when claim.id = '52000000-0000-4000-8000-000000000026'::uuid
            then 'The brief and confrontational nature of Beechey''s visit to Rapanui makes this seem unlikely'
        when claim.id between '52000000-0000-4000-8000-000000000030'::uuid and '52000000-0000-4000-8000-000000000032'::uuid
            then 'reached England in 1828 or 1835'
        when claim.id between '52000000-0000-4000-8000-000000000040'::uuid and '52000000-0000-4000-8000-000000000041'::uuid
            then 'Oldman Collection'
        when claim.id between '52000000-0000-4000-8000-000000000050'::uuid and '52000000-0000-4000-8000-000000000054'::uuid
            then 'Gift of the New Zealand Government'
        when claim.id between '52000000-0000-4000-8000-000000000060'::uuid and '52000000-0000-4000-8000-000000000061'::uuid
            then 'Museum of New Zealand Te Papa Tongarewa'
        else null
    end
from knowledge.claim as claim
where claim.subject_id >= '82000000-0000-4000-8000-000000000001'::uuid
  and claim.subject_id <= '82000000-0000-4000-8000-000000000005'::uuid;

insert into knowledge.claim_evidence (id, claim_id, source_id, relationship, locator, excerpt)
values
    ('62000000-0000-4000-8000-000000000001', '52000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001', 'supports', 'Catalogue object page', 'OL000342'),
    ('62000000-0000-4000-8000-000000000002', '52000000-0000-4000-8000-000000000002', '42000000-0000-4000-8000-000000000001', 'supports', 'Catalogue publisher', 'Museum of New Zealand Te Papa Tongarewa'),
    ('62000000-0000-4000-8000-000000000003', '52000000-0000-4000-8000-000000000003', '42000000-0000-4000-8000-000000000002', 'supports', 'Document title', 'Te Papa moai kavakava'),
    ('62000000-0000-4000-8000-000000000004', '52000000-0000-4000-8000-000000000004', '42000000-0000-4000-8000-000000000002', 'supports', 'Document author', 'Paula Rossetti'),
    ('62000000-0000-4000-8000-000000000005', '52000000-0000-4000-8000-000000000005', '42000000-0000-4000-8000-000000000001', 'supports', 'Object title', 'moai kavakava'),
    ('62000000-0000-4000-8000-000000000006', '52000000-0000-4000-8000-000000000006', '42000000-0000-4000-8000-000000000001', 'supports', 'Object classification', 'moai kavakava');

commit;
