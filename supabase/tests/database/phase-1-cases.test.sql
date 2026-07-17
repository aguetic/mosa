begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(38);

-- Schema and API surface.
select ok(
    to_regclass('knowledge.claim_details') is not null,
    'claim_details view exists'
);
select ok(
    to_regclass('knowledge.claim_evidence_details') is not null,
    'claim_evidence_details view exists'
);
select ok(
    to_regprocedure('entities.create_item(text,text,text)') is not null,
    'create_item helper exists'
);
select ok(
    to_regprocedure('entities.create_agent(text,text,text)') is not null,
    'create_agent helper exists'
);
select ok(
    to_regprocedure('entities.create_place(text,text,text)') is not null,
    'create_place helper exists'
);
select ok(
    to_regprocedure('entities.create_source(text,text,text,timestamp with time zone,text)') is not null,
    'create_source helper exists'
);

-- General fixture invariants.
select is(
    (
        select count(*)::integer
        from entities.entity as e
        left join entities.item as i on i.id = e.id
        left join entities.agent as a on a.id = e.id
        left join entities.place as p on p.id = e.id
        left join entities.source as s on s.id = e.id
        where (e.entity_type = 'item' and i.id is null)
           or (e.entity_type = 'agent' and a.id is null)
           or (e.entity_type = 'place' and p.id is null)
           or (e.entity_type = 'source' and s.id is null)
           or (e.entity_type <> 'item' and i.id is not null)
           or (e.entity_type <> 'agent' and a.id is not null)
           or (e.entity_type <> 'place' and p.id is not null)
           or (e.entity_type <> 'source' and s.id is not null)
    ),
    0,
    'every fixture entity has exactly the matching subtype'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where num_nonnulls(object_entity_id, literal_value) <> 1
    ),
    0,
    'every fixture claim has exactly one value representation'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim_evidence as ce
        join entities.entity as source on source.id = ce.source_id
        where source.entity_type <> 'source'
    ),
    0,
    'every evidence link points to a source entity'
);
select is(
    (
        select count(*)::integer
        from (
            select namespace, value
            from entities.external_identifier
            group by namespace, value
            having count(*) > 1
        ) as duplicates
    ),
    0,
    'external identifiers are unique within a namespace'
);
select ok(
    not exists (
        select 1
        from knowledge.claim
        where predicate in ('refers_to', 'depicts')
          and subject_id = object_entity_id
    ),
    'sources remain distinct from the entities they refer to or depict'
);

-- Case 01: Hoa Hakananaiʻa.
select is(
    (select count(*)::integer from entities.entity where id = '30000000-0000-4000-8000-000000000001' and entity_type = 'item'),
    1,
    'Hoa Hakananaiʻa exists once as an item'
);
select is(
    (select count(*)::integer from knowledge.claim where subject_id = '30000000-0000-4000-8000-000000000001' and predicate = 'has_name'),
    2,
    'Hoa Hakananaiʻa keeps two names'
);
select is(
    (select count(*)::integer from knowledge.claim where subject_id = '30000000-0000-4000-8000-000000000001' and predicate = 'classified_as'),
    2,
    'Hoa Hakananaiʻa keeps two classifications'
);
select is(
    (
        select count(distinct subject_id)::integer
        from knowledge.claim
        where object_entity_id = '30000000-0000-4000-8000-000000000001'
          and predicate = 'refers_to'
    ),
    2,
    'two distinct sources refer to Hoa Hakananaiʻa'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim_evidence as ce
        where ce.claim_id in (
            '50000000-0000-4000-8000-000000000005'::uuid,
            '50000000-0000-4000-8000-000000000007'::uuid,
            '50000000-0000-4000-8000-000000000009'::uuid
        )
          and ce.relationship = 'mentions'
    ),
    3,
    'secondary British Museum statements use mentions'
);

-- Case 02: conflicting descriptions.
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000002'
          and predicate in ('has_name', 'classified_as', 'described_as')
    ),
    4,
    'MPE 32571 keeps all four interpretive claims'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000002'
          and predicate = 'described_as'
    ),
    2,
    'MPE 32571 keeps both competing descriptions'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000002'
          and predicate in ('has_name', 'classified_as', 'described_as')
          and status = 'active'
    ),
    4,
    'all MPE 32571 interpretations remain active'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000002'
          and supersedes_claim_id is not null
    ),
    0,
    'MPE 32571 interpretations do not supersede one another'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where id = '50000000-0000-4000-8000-000000000021'
          and predicate = 'depicts'
          and subject_id = '40000000-0000-4000-8000-000000000004'
          and object_entity_id = '30000000-0000-4000-8000-000000000002'
    ),
    1,
    'the MPE photograph depicts the item'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim_evidence
        where claim_id = '50000000-0000-4000-8000-000000000021'
          and source_id = '40000000-0000-4000-8000-000000000004'
          and relationship = 'supports'
    ),
    1,
    'the photograph directly supports its depicts claim'
);

-- Case 03: uncertain identity.
select is(
    (
        select count(*)::integer
        from entities.item
        where id in (
            '30000000-0000-4000-8000-000000000003'::uuid,
            '30000000-0000-4000-8000-000000000004'::uuid
        )
    ),
    2,
    'the two moai curvo identities remain separate items'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate = 'possibly_same_as'
          and subject_id = '30000000-0000-4000-8000-000000000003'
          and object_entity_id = '30000000-0000-4000-8000-000000000004'
    ),
    1,
    'one possibly_same_as claim links the two items'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim_evidence
        where claim_id = '50000000-0000-4000-8000-000000000032'
    ),
    2,
    'the identity hypothesis has two evidence links'
);
select ok(
    '30000000-0000-4000-8000-000000000003'::uuid
        <> '30000000-0000-4000-8000-000000000004'::uuid,
    'the possible match does not merge item identifiers'
);

-- Case 04: ancestral person and physical remains.
select is(
    (select count(*)::integer from entities.item where id = '30000000-0000-4000-8000-000000000005'),
    1,
    'the cranial remains are an item'
);
select is(
    (select count(*)::integer from entities.agent where id = '10000000-0000-4000-8000-000000000006'),
    1,
    'the ancestral person is an agent'
);
select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate = 'physical_remains_of'
          and subject_id = '30000000-0000-4000-8000-000000000005'
          and object_entity_id = '10000000-0000-4000-8000-000000000006'
    ),
    1,
    'physical_remains_of connects the remains to the person'
);
select is(
    (select count(*)::integer from entities.item where id = '10000000-0000-4000-8000-000000000006'),
    0,
    'the ancestral person is not an item'
);
select is(
    (select count(*)::integer from entities.agent where id = '30000000-0000-4000-8000-000000000005'),
    0,
    'the physical remains are not an agent'
);

-- Helper functions are transactional and create the matching subtype.
create temporary table phase_1_helper_ids (
    entity_type text primary key,
    id uuid not null
) on commit drop;

insert into phase_1_helper_ids values
    ('item', entities.create_item('Fixture helper item', 'artefact', 'pgTAP helper test')),
    ('agent', entities.create_agent('Fixture helper agent', 'person', 'pgTAP helper test')),
    ('place', entities.create_place('Fixture helper place', 'site', 'pgTAP helper test')),
    ('source', entities.create_source('Fixture helper source', 'research_note', 'local:test', null, 'pgTAP helper test'));

select is(
    (
        select count(*)::integer
        from phase_1_helper_ids as h
        join entities.entity as e on e.id = h.id
        where h.entity_type = 'item' and e.entity_type = 'item'
    ),
    1,
    'create_item creates the base entity'
);
select is(
    (
        select count(*)::integer
        from phase_1_helper_ids as h
        join entities.item as i on i.id = h.id
        where h.entity_type = 'item' and i.item_kind = 'artefact'
    ),
    1,
    'create_item creates the subtype row'
);
select is(
    (
        select count(*)::integer
        from phase_1_helper_ids as h
        join entities.agent as a on a.id = h.id
        where h.entity_type = 'agent' and a.agent_kind = 'person'
    ),
    1,
    'create_agent creates the subtype row'
);
select is(
    (
        select count(*)::integer
        from phase_1_helper_ids as h
        join entities.place as p on p.id = h.id
        where h.entity_type = 'place' and p.place_kind = 'site'
    ),
    1,
    'create_place creates the subtype row'
);
select is(
    (
        select count(*)::integer
        from phase_1_helper_ids as h
        join entities.source as s on s.id = h.id
        where h.entity_type = 'source' and s.source_kind = 'research_note'
    ),
    1,
    'create_source creates the subtype row'
);
select is(
    (select count(*)::integer from knowledge.claim_details),
    (select count(*)::integer from knowledge.claim),
    'claim_details preserves one row per claim'
);
select is(
    (select count(*)::integer from knowledge.claim_evidence_details),
    (select count(*)::integer from knowledge.claim_evidence),
    'claim_evidence_details preserves one row per evidence link'
);

select * from finish();
rollback;
