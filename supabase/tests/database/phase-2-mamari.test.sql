begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(11);

-- Minimal schema contract.

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

-- Fixture shape and unresolved early accounts.

select ok(
    (
        select count(*) = 8
        from provenance.event
        where id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000009'::uuid
    )
    and (
        select count(distinct subject_id) = 8
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000009'::uuid
          and predicate = 'moved_item'
          and object_entity_id =
              '31000000-0000-4000-8000-000000000001'::uuid
    ),
    'Mamari has eight event anchors and every event identifies the stable item'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000003'::uuid
    )
    and not exists (
        select 1
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
    'the Roussel and Zumbohm account chains remain separate'
);

-- One Paris event with shared facts and correlated alternatives.

select ok(
    exists (
        select 1
        from provenance.event
        where id = '81000000-0000-4000-8000-000000000005'::uuid
          and event_kind = 'transfer'
    )
    and not exists (
        select 1
        from provenance.event
        where id = '81000000-0000-4000-8000-000000000006'::uuid
    )
    and exists (
        select 1
        from entities.agent
        where id = '11000000-0000-4000-8000-000000000008'::uuid
          and agent_kind = 'organisation'
    ),
    'one Paris deposit event refers to the Missionary Museum organisation'
);

select ok(
    (
        with expected(predicate, object_entity_id) as (
            values
                (
                    'moved_item',
                    '31000000-0000-4000-8000-000000000001'::uuid
                ),
                (
                    'occurred_at',
                    '21000000-0000-4000-8000-000000000003'::uuid
                ),
                (
                    'transferred_to',
                    '11000000-0000-4000-8000-000000000008'::uuid
                )
        )
        select count(*) = 3
        from expected
        where (
            select count(*)
            from knowledge.claim
            where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
              and knowledge.claim.predicate = expected.predicate
              and knowledge.claim.object_entity_id = expected.object_entity_id
        ) = 1
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'moved_to'
    ),
    'the Paris event stores its shared item, location and recipient exactly once'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1888'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000005'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1892'
    ),
    'the Paris event retains both actor and date alternatives'
);

select ok(
    (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000044'::uuid
    ) = (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000045'::uuid
    )
    and (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000046'::uuid
    ) = (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000047'::uuid
    )
    and (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000044'::uuid
    ) <> (
        select jsonb_build_array(source_id, locator, excerpt)
        from knowledge.claim_evidence
        where claim_id = '51000000-0000-4000-8000-000000000046'::uuid
    )
    and (
        select count(distinct jsonb_build_array(source_id, locator, excerpt)) = 2
        from knowledge.claim_evidence
        where claim_id in (
            '51000000-0000-4000-8000-000000000044'::uuid,
            '51000000-0000-4000-8000-000000000045'::uuid,
            '51000000-0000-4000-8000-000000000046'::uuid,
            '51000000-0000-4000-8000-000000000047'::uuid
        )
    ),
    'each Paris actor/date pair shares one distinct existing evidence context'
);

-- Later ordering and general safeguards.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000007'::uuid
          and predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000005'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000008'::uuid
          and predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000007'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000009'::uuid
          and predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000008'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where predicate = 'preceded_by'
          and object_entity_id = '81000000-0000-4000-8000-000000000006'::uuid
    ),
    'the later relocation sequence follows the single Paris event'
);

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

select ok(
    not exists (
        select 1
        from entities.entity
        where entity_type = 'event'
          and working_label ilike '%1974%'
    )
    and not exists (
        select 1
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
    'the fixture does not invent a 1974 move, ownership, legality or consent'
);

select * from finish();
rollback;
