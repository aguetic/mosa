begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(15);

-- Schema smoke tests.

select has_table(
    'provenance',
    'event',
    'provenance.event exists'
);

select fk_ok(
    'provenance',
    'event',
    'id',
    'entities',
    'entity',
    'id',
    'event identities share the entity identity space'
);

select ok(
    to_regprocedure('provenance.create_event(text,text,text)') is not null,
    'create_event helper exists'
);

-- Fixture shape.

select is(
    (
        select count(*)::integer
        from provenance.event
        where id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000009'::uuid
    ),
    9,
    'Mamari has nine event anchors'
);

select is(
    (
        select count(distinct subject_id)::integer
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000009'::uuid
          and predicate = 'moved_item'
          and object_entity_id =
              '31000000-0000-4000-8000-000000000001'::uuid
    ),
    9,
    'every Mamari event identifies the stable Mamari item'
);

-- Roussel account.

select is(
    (
        with expected(subject_id, predicate, object_entity_id) as (
            values
                (
                    '81000000-0000-4000-8000-000000000001'::uuid,
                    'moved_from',
                    '21000000-0000-4000-8000-000000000001'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000001'::uuid,
                    'moved_to',
                    '21000000-0000-4000-8000-000000000002'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000001'::uuid,
                    'carried_out_by',
                    '11000000-0000-4000-8000-000000000002'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000002'::uuid,
                    'transferred_to',
                    '11000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000002'::uuid,
                    'preceded_by',
                    '81000000-0000-4000-8000-000000000001'::uuid
                )
        )
        select count(*)::integer
        from expected
        where exists (
            select 1
            from knowledge.claim
            where knowledge.claim.subject_id = expected.subject_id
              and knowledge.claim.predicate = expected.predicate
              and knowledge.claim.object_entity_id =
                  expected.object_entity_id
        )
    ),
    5,
    'the Roussel movement and transfer chain is structured'
);

-- Zumbohm account.

select is(
    (
        with expected(subject_id, predicate, object_entity_id) as (
            values
                (
                    '81000000-0000-4000-8000-000000000003'::uuid,
                    'moved_from',
                    '21000000-0000-4000-8000-000000000001'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000003'::uuid,
                    'carried_out_by',
                    '11000000-0000-4000-8000-000000000001'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000004'::uuid,
                    'moved_to',
                    '21000000-0000-4000-8000-000000000002'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000004'::uuid,
                    'transferred_to',
                    '11000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000004'::uuid,
                    'preceded_by',
                    '81000000-0000-4000-8000-000000000003'::uuid
                )
        )
        select count(*)::integer
        from expected
        where exists (
            select 1
            from knowledge.claim
            where knowledge.claim.subject_id = expected.subject_id
              and knowledge.claim.predicate = expected.predicate
              and knowledge.claim.object_entity_id =
                  expected.object_entity_id
        )
    ),
    5,
    'the Zumbohm movement and transfer chain is structured'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id in (
            '81000000-0000-4000-8000-000000000001'::uuid,
            '81000000-0000-4000-8000-000000000002'::uuid
        )
          and object_entity_id in (
            '81000000-0000-4000-8000-000000000003'::uuid,
            '81000000-0000-4000-8000-000000000004'::uuid
        )
    ),
    0,
    'the Roussel and Zumbohm account chains are not merged'
);

-- Paris alternatives.

select ok(
    (
        select count(*) = 2
        from provenance.event
        where id in (
            '81000000-0000-4000-8000-000000000005'::uuid,
            '81000000-0000-4000-8000-000000000006'::uuid
        )
    )
    and exists (
        select 1
        from entities.agent
        where id = '11000000-0000-4000-8000-000000000008'::uuid
          and agent_kind = 'organisation'
    ),
    'the Paris alternatives are separate and the Missionary Museum is an organisation'
);

select is(
    (
        with expected(subject_id, predicate, object_entity_id) as (
            values
                (
                    '81000000-0000-4000-8000-000000000005'::uuid,
                    'occurred_at',
                    '21000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000005'::uuid,
                    'transferred_to',
                    '11000000-0000-4000-8000-000000000008'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000005'::uuid,
                    'carried_out_by',
                    '11000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000006'::uuid,
                    'occurred_at',
                    '21000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000006'::uuid,
                    'transferred_to',
                    '11000000-0000-4000-8000-000000000008'::uuid
                ),
                (
                    '81000000-0000-4000-8000-000000000006'::uuid,
                    'carried_out_by',
                    '11000000-0000-4000-8000-000000000005'::uuid
                )
        )
        select count(*)::integer
        from expected
        where exists (
            select 1
            from knowledge.claim
            where knowledge.claim.subject_id = expected.subject_id
              and knowledge.claim.predicate = expected.predicate
              and knowledge.claim.object_entity_id =
                  expected.object_entity_id
        )
    ),
    6,
    'the Paris accounts distinguish location, recipient and active agent'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id =
            '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1888'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id =
            '81000000-0000-4000-8000-000000000006'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1892'
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id in (
            '81000000-0000-4000-8000-000000000005'::uuid,
            '81000000-0000-4000-8000-000000000006'::uuid
        )
          and predicate = 'moved_to'
    ),
    'the Paris accounts retain separate dates without overstating movement to Paris'
);

-- Later sequence.

select ok(
    (
        select count(*) = 3
        from provenance.event
        where id in (
            '81000000-0000-4000-8000-000000000007'::uuid,
            '81000000-0000-4000-8000-000000000008'::uuid,
            '81000000-0000-4000-8000-000000000009'::uuid
        )
          and event_kind = 'relocation'
    )
    and not exists (
        select 1
        from entities.entity
        where entity_type = 'event'
          and working_label ilike '%1974%'
    ),
    'three supported later relocations exist and no 1974 Mamari event is invented'
);

-- General invariants.

select is(
    (
        select count(*)::integer
        from (
            select claim.id
            from knowledge.claim as claim
            left join knowledge.claim_evidence as evidence
                on evidence.claim_id = claim.id
            where claim.subject_id between
                '81000000-0000-4000-8000-000000000001'::uuid
                and
                '81000000-0000-4000-8000-000000000009'::uuid
            group by claim.id
            having count(evidence.id) = 0
        ) as claims_without_evidence
    ),
    0,
    'every Mamari event claim has evidence'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000009'::uuid
          and predicate in (
              'owned_by',
              'lawfully_owned_by',
              'consented_by',
              'lawful_transfer',
              'was_gift'
          )
    ),
    0,
    'the fixture does not invent ownership, legality or consent'
);

select ok(
    exists (
        select 1
        from knowledge.claim_details
        where subject_type = 'event'
          and predicate = 'moved_item'
          and object_entity_type = 'item'
    ),
    'the standard claim view exposes provenance event claims'
);

select * from finish();
rollback;
