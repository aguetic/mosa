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

-- Seven event anchors.

select ok(
    (
        select count(*) = 7
        from provenance.event
        where id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000007'::uuid
    )
    and (
        select count(distinct subject_id) = 7
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000007'::uuid
          and predicate in ('moved_item', 'held_item')
          and object_entity_id =
              '31000000-0000-4000-8000-000000000001'::uuid
    ),
    'Mamari has seven event anchors and every event identifies the stable item'
);

-- Roussel account is a single merged event.

select ok(
    exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_from'
          and object_entity_id = '21000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_to'
          and object_entity_id = '21000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '11000000-0000-4000-8000-000000000003'::uuid
    ),
    'one Roussel event contains origin, destination, actor and recipient'
);

-- Zumbohm account is a single merged event.

select ok(
    exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_from'
          and object_entity_id = '21000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_to'
          and object_entity_id = '21000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '11000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1870'
    ),
    'one Zumbohm event contains origin, destination, actor, recipient and date'
);

-- Two separate Paris provisional accounts.

select ok(
    exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1888'
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'occurred_at'
          and object_entity_id = '21000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '11000000-0000-4000-8000-000000000008'::uuid
    ),
    'the Jaussen Paris event has the 1888 date and shared Paris facts'
);

select ok(
    exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '11000000-0000-4000-8000-000000000005'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1892'
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'occurred_at'
          and object_entity_id = '21000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '11000000-0000-4000-8000-000000000008'::uuid
    ),
    'the French Navy Paris event has the 1892 date and shared Paris facts'
);

-- Later dated relocations.

select ok(
    exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1905'
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000006'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1953'
    )
    and exists (
        select 1 from knowledge.claim
        where subject_id = '81000000-0000-4000-8000-000000000007'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1964'
    ),
    'three later dated relocations exist'
);

-- No ordering or involved predicates.

select ok(
    not exists (
        select 1 from knowledge.claim
        where predicate = 'preceded_by'
          and subject_id between
              '81000000-0000-4000-8000-000000000001'::uuid
              and
              '81000000-0000-4000-8000-000000000007'::uuid
    )
    and not exists (
        select 1 from knowledge.claim
        where predicate = 'involved'
          and subject_id between
              '81000000-0000-4000-8000-000000000001'::uuid
              and
              '81000000-0000-4000-8000-000000000007'::uuid
    ),
    'Phase 2 Mamari fixtures contain no preceded_by or involved claims'
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
                '81000000-0000-4000-8000-000000000007'::uuid
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
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000007'::uuid
          and predicate in (
              'owned_by',
              'lawfully_owned_by',
              'consented_by',
              'lawful_transfer',
              'was_gift'
          )
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '81000000-0000-4000-8000-000000000001'::uuid
            and
            '81000000-0000-4000-8000-000000000007'::uuid
          and predicate = 'occurred_during'
          and (
              literal_value ->> 'verbatim' = '1974'
              or literal_value ->> 'earliest' = '1974'
              or literal_value ->> 'latest' = '1974'
              or literal_value -> 'alternatives' ? '1974'
          )
    ),
    'the fixture does not invent a 1974 move, ownership, legality or consent'
);

select * from finish();
rollback;
