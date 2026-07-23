begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(14);

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

-- Five event anchors exist.

select is(
    (
        select count(*)::integer
        from provenance.event
        where id between
            '82000000-0000-4000-8000-000000000001'::uuid
            and
            '82000000-0000-4000-8000-000000000005'::uuid
    ),
    5,
    'five Te Papa event anchors exist'
);

-- HMS Blossom hypothesis exists and retains structured roles.

select ok(
    exists (
        select 1
        from provenance.event as event
        join entities.entity as entity on entity.id = event.id
        where event.id = '82000000-0000-4000-8000-000000000001'::uuid
          and entity.working_label = 'Possible HMS Blossom collection hypothesis'
          and event.event_kind = 'unknown'
    ),
    'HMS Blossom collection hypothesis exists as an event anchor'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_item'
          and object_entity_id = '32000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '12000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1825'
          and literal_value ->> 'interpretation' = 'hypothesis'
    ),
    'HMS Blossom event has moved_item, expedition carried_out_by and 1825 occurred_during'
);

-- Same event has qualifying evidence and is not rejected.

select ok(
    exists (
        select 1
        from knowledge.claim as claim
        join knowledge.claim_evidence as evidence on evidence.claim_id = claim.id
        where claim.subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and evidence.relationship = 'qualifies'
          and evidence.source_id = '42000000-0000-4000-8000-000000000001'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000001'::uuid
          and status = 'rejected'
    ),
    'the same HMS Blossom event has qualifying evidence and is not rejected'
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
    )
    and not exists (
        select 1
        from knowledge.claim
        where predicate = 'preceded_by'
          and (
              subject_id = '82000000-0000-4000-8000-000000000002'::uuid
              or object_entity_id = '82000000-0000-4000-8000-000000000001'::uuid
          )
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
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '82000000-0000-4000-8000-000000000001'::uuid
            and
            '82000000-0000-4000-8000-000000000005'::uuid
          and (
              predicate ilike '%gift%'
              or literal_value ->> 'value' ilike '%gift%'
          )
          and predicate <> 'described_as'
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
            '82000000-0000-4000-8000-000000000005'::uuid
          and predicate in (
              'owned_by',
              'lawfully_owned_by',
              'consented_by',
              'lawful_transfer',
              'was_gift'
          )
    ),
    'no ownership, legality or consent predicates exist'
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
                '82000000-0000-4000-8000-000000000005'::uuid
            group by claim.id
            having count(evidence.id) = 0
        ) as claims_without_evidence
    ),
    0,
    'every Te Papa event claim has evidence'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '82000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'holding_agent'
          and object_entity_id = '12000000-0000-4000-8000-000000000005'::uuid
    ),
    'current Te Papa custody is represented separately'
);

select * from finish();
rollback;
