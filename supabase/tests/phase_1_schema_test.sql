begin;
select plan(29);

-- ============================================================
-- Table existence
-- ============================================================

select has_table('entities', 'entity', 'entities.entity exists');
select has_table('entities', 'item', 'entities.item exists');
select has_table('entities', 'agent', 'entities.agent exists');
select has_table('entities', 'place', 'entities.place exists');
select has_table('entities', 'source', 'entities.source exists');
select has_table(
    'entities',
    'external_identifier',
    'entities.external_identifier exists'
);
select has_table('knowledge', 'claim', 'knowledge.claim exists');
select has_table(
    'knowledge',
    'claim_evidence',
    'knowledge.claim_evidence exists'
);

-- ============================================================
-- Subtype IDs are primary and foreign keys
-- ============================================================

select col_is_pk('entities', 'item', 'id', 'item.id is primary key');
select col_is_pk('entities', 'agent', 'id', 'agent.id is primary key');
select col_is_pk('entities', 'place', 'id', 'place.id is primary key');
select col_is_pk('entities', 'source', 'id', 'source.id is primary key');

select fk_ok(
    'entities', 'item', 'id',
    'entities', 'entity', 'id',
    'item.id references entity.id'
);
select fk_ok(
    'entities', 'agent', 'id',
    'entities', 'entity', 'id',
    'agent.id references entity.id'
);
select fk_ok(
    'entities', 'place', 'id',
    'entities', 'entity', 'id',
    'place.id references entity.id'
);
select fk_ok(
    'entities', 'source', 'id',
    'entities', 'entity', 'id',
    'source.id references entity.id'
);

-- ============================================================
-- Subtype enforcement and claim value constraints
-- ============================================================

select throws_ok(
    $$
    insert into entities.item (id, item_kind)
    values ('00000000-0000-4000-8000-000000000001', 'artefact')
    $$,
    'P0001',
    'Entity 00000000-0000-4000-8000-000000000001 has type agent, but this table requires type item',
    'item row cannot reference an agent entity'
);

select throws_ok(
    $$
    insert into knowledge.claim (subject_id, predicate)
    values (
        '00000000-0000-4000-8000-000000000002',
        'has_name'
    )
    $$,
    '23514',
    NULL,
    'claim without object or literal is rejected'
);

select throws_ok(
    $$
    insert into knowledge.claim (
        subject_id,
        predicate,
        object_entity_id,
        literal_value
    )
    values (
        '00000000-0000-4000-8000-000000000002',
        'related_to',
        '00000000-0000-4000-8000-000000000003',
        '{"type":"text","value":"invalid second value"}'
    )
    $$,
    '23514',
    NULL,
    'claim with both object and literal is rejected'
);

select throws_ok(
    $$
    insert into knowledge.claim (
        subject_id,
        predicate,
        literal_value
    )
    values (
        '00000000-0000-4000-8000-000000000002',
        'has_name',
        '"not-an-object"'::jsonb
    )
    $$,
    '23514',
    NULL,
    'literal claim value must be a JSON object'
);

select throws_ok(
    $$
    insert into knowledge.claim_evidence (
        claim_id,
        source_id,
        relationship,
        locator
    )
    values (
        '10000000-0000-4000-8000-000000000001',
        '00000000-0000-4000-8000-000000000004',
        'supports',
        '   '
    )
    $$,
    '23514',
    NULL,
    'evidence locator must be non-blank'
);

select col_not_null(
    'knowledge',
    'claim_evidence',
    'source_id',
    'claim_evidence.source_id is required'
);
select col_not_null(
    'knowledge',
    'claim_evidence',
    'locator',
    'claim_evidence.locator is required'
);

-- ============================================================
-- Access control: anon denied, authenticated allowed
-- ============================================================

set local role anon;
select throws_ok(
    $$ select count(*) from entities.entity $$,
    '42501',
    NULL,
    'anonymous users cannot read entities.entity'
);
reset role;

set local role authenticated;
select lives_ok(
    $$ select count(*) from entities.entity $$,
    'authenticated users can read entities.entity'
);
select lives_ok(
    $$
    insert into entities.entity (entity_type, working_label)
    values ('item', 'pgTAP temporary item')
    $$,
    'authenticated users can write entities.entity'
);
reset role;

-- ============================================================
-- Referential behaviour
-- ============================================================

select throws_ok(
    $$
    delete from entities.entity
    where id = '00000000-0000-4000-8000-000000000002'
    $$,
    '23503',
    NULL,
    'deleting an entity referenced by claims is restricted'
);

select is(
    (
        select count(*)::int
        from knowledge.claim_evidence
        where claim_id = '10000000-0000-4000-8000-000000000001'
    ),
    1,
    'seed claim has one evidence link before delete'
);

delete from knowledge.claim
where id = '10000000-0000-4000-8000-000000000001';

select is(
    (
        select count(*)::int
        from knowledge.claim_evidence
        where claim_id = '10000000-0000-4000-8000-000000000001'
    ),
    0,
    'deleting a claim cascades to its evidence links'
);

select * from finish();
rollback;
