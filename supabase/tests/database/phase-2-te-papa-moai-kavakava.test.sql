begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(15);

-- Te Papa item exists.

select ok(
    exists (
        select 1
        from entities.item as item
        join entities.entity as entity on entity.id = item.id
        where item.id = '32000000-0000-4000-8000-000000000001'::uuid
          and entity.working_label = 'Te Papa moai kavakava'
    )
    and exists (
        select 1
        from entities.external_identifier
        where entity_id = '32000000-0000-4000-8000-000000000001'::uuid
          and value = 'OL000342'
    ),
    'Te Papa moai kavakava item exists with inventory OL000342'
);

-- Four event anchors exist.

select is(
    (
        select count(*)::integer
        from provenance.event
        where id between
            '82000000-0000-4000-8000-000000000001'::uuid
            and
            '82000000-0000-4000-8000-000000000004'::uuid
    ),
    4,
    'four Te Papa event anchors exist'
);

select ok(
    not exists (
        select 1
        from provenance.event
        where id = '82000000-0000-4000-8000-000000000005'::uuid
    ),
    'no current-custody event exists'
);

-- HMS Blossom hypothesis remains active with reporting and qualifying evidence.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_item'
          and object_entity_id = '32000000-0000-4000-8000-000000000001'::uuid
          and status = 'active'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '12000000-0000-4000-8000-000000000002'::uuid
          and status = 'active'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1825'
          and status = 'active'
    ),
    'the 1825 event remains active with expedition carried_out_by'
);

select ok(
    (
        select count(distinct claim.id) = 5
        from knowledge.claim as claim
        join knowledge.claim_evidence as mentions
            on mentions.claim_id = claim.id
           and mentions.relationship = 'mentions'
        join knowledge.claim_evidence as qualifies
            on qualifies.claim_id = claim.id
           and qualifies.relationship = 'qualifies'
        where claim.subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and claim.predicate in (
              'moved_item',
              'occurred_at',
              'carried_out_by',
              'occurred_during',
              'described_as'
          )
    ),
    'the 1825 claims have both reporting and qualifying evidence'
);

-- Arrival preserves alternative dates and is not collection.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1828 or 1835'
          and literal_value ->> 'interpretation' = 'alternatives'
          and literal_value -> 'alternatives' ? '1828'
          and literal_value -> 'alternatives' ? '1835'
    ),
    'arrival event preserves 1828 and 1835 as structured alternatives'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_to'
          and object_entity_id = '22000000-0000-4000-8000-000000000002'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000002'::uuid
          and predicate in ('occurred_at', 'carried_out_by', 'involved')
    ),
    'arrival in England is not modelled as the Rapa Nui collection'
);

-- Oldman Collection and government transfer remain separate.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'held_item'
          and object_entity_id = '32000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'holding_agent'
          and object_entity_id = '12000000-0000-4000-8000-000000000003'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'occurred_during'
    ),
    'Oldman Collection remains a separate undated holding episode'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_from'
          and object_entity_id = '12000000-0000-4000-8000-000000000004'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '12000000-0000-4000-8000-000000000005'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1992'
    ),
    'New Zealand Government transfer is a separate 1992 event'
);

-- Gift remains descriptive; no ownership/legal/consent predicates.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'described_as'
          and literal_value ->> 'value' = 'Gift of the New Zealand Government'
    )
    and not exists (
        select 1
        from provenance.event
        where id = '82000000-0000-4000-8000-000000000004'::uuid
          and event_kind = 'gift'
    ),
    'gift exists only as described_as wording'
);

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '82000000-0000-4000-8000-000000000001'::uuid
            and
            '82000000-0000-4000-8000-000000000004'::uuid
          and predicate in (
              'owned_by',
              'lawfully_owned_by',
              'consented_by',
              'lawful_transfer',
              'was_gift',
              'involved',
              'preceded_by'
          )
    )
    and not exists (
        select 1
        from knowledge.claim
        where predicate in ('involved', 'preceded_by')
          and (
              subject_id = '32000000-0000-4000-8000-000000000001'::uuid
              or object_entity_id = '32000000-0000-4000-8000-000000000001'::uuid
          )
    ),
    'no involved, preceded_by, ownership, legality or consent claims exist'
);

-- Current custody is a direct item state.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '32000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'held_by'
          and object_entity_id = '12000000-0000-4000-8000-000000000005'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '32000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'located_at'
          and object_entity_id = '22000000-0000-4000-8000-000000000003'::uuid
    ),
    'the item has direct held_by and located_at claims'
);

-- Agents remain separate; all event claims have evidence.

select ok(
    (
        select count(*) = 5
        from entities.agent
        where id between
            '12000000-0000-4000-8000-000000000001'::uuid
            and
            '12000000-0000-4000-8000-000000000005'::uuid
    ),
    'expedition, person, collection, government and museum remain separate agents'
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
                '82000000-0000-4000-8000-000000000001'::uuid
                and
                '82000000-0000-4000-8000-000000000004'::uuid
            group by claim.id
            having count(evidence.id) = 0
        ) as claims_without_evidence
    ),
    0,
    'every Te Papa event claim has evidence'
);

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '82000000-0000-4000-8000-000000000001'::uuid
            and
            '82000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'holding_agent'
          and object_entity_id = '12000000-0000-4000-8000-000000000005'::uuid
    ),
    'current Te Papa custody is not represented as an event holding claim'
);

select * from finish();
rollback;
