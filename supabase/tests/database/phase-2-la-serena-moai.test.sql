begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(14);

-- Stable item identity.

select ok(
    exists (
        select 1
        from entities.item as item
        join entities.entity as entity on entity.id = item.id
        where item.id = '34000000-0000-4000-8000-000000000001'::uuid
          and item.item_kind = 'artefact'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '34000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'has_name'
          and literal_value ->> 'value' = 'La Serena moai'
    ),
    'La Serena moai has one stable item identity'
);

-- Exactly one provisional 1952 event.

select is(
    (
        select count(*)::integer
        from provenance.event
        where id = '84000000-0000-4000-8000-000000000001'::uuid
          and event_kind = 'relocation'
    ),
    1,
    'exactly one provisional 1952 event exists with event_kind relocation'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_item'
          and object_entity_id = '34000000-0000-4000-8000-000000000001'::uuid
          and status = 'active'
    )
    and (
        select count(*)::integer
        from provenance.event as event
        join knowledge.claim as moved
            on moved.subject_id = event.id
           and moved.predicate = 'moved_item'
           and moved.object_entity_id = '34000000-0000-4000-8000-000000000001'::uuid
        join knowledge.claim as during
            on during.subject_id = event.id
           and during.predicate = 'occurred_during'
           and during.literal_value ->> 'verbatim' = '1952'
        where event.id >= '84000000-0000-4000-8000-000000000000'::uuid
          and event.id <  '84000000-0000-4000-8000-000000000100'::uuid
    ) = 1,
    'the event links to the item through moved_item once with year 1952'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'type' = 'date_interval'
          and literal_value ->> 'verbatim' = '1952'
          and literal_value ->> 'precision' = 'year'
          and literal_value ->> 'interpretation' = 'exact'
          and literal_value ->> 'earliest' = '1952'
          and literal_value ->> 'latest' = '1952'
    ),
    'occurred_during has year precision and exact value 1952'
);

-- Gift wording remains described_as with no asserting agent and mentions evidence.

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '54000000-0000-4000-8000-000000000022'::uuid
          and subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and asserted_by_agent_id is null
          and literal_value ->> 'value' = 'se dice que fue un regalo del pueblo Rapa Nui'
          and literal_value ->> 'language' = 'es'
    ),
    'the gift wording remains a described_as literal with no asserting agent'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '54000000-0000-4000-8000-000000000022'::uuid
          and source_id = '44000000-0000-4000-8000-000000000001'::uuid
          and relationship = 'mentions'
          and excerpt = 'se dice que fue un regalo del pueblo Rapa Nui'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '44000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'authored_by'
          and object_entity_id = '10000000-0000-4000-8000-000000000001'::uuid
    ),
    'Paula’s note is attached to the gift claim using mentions'
);

-- No invented community agent from the gift wording.

select ok(
    not exists (
        select 1
        from knowledge.claim
        where predicate = 'has_name'
          and literal_value ->> 'value' ilike '%Rapa Nui people%'
    )
    and not exists (
        select 1
        from knowledge.claim
        where predicate = 'has_name'
          and literal_value ->> 'value' ilike '%pueblo Rapa Nui%'
    )
    and (
        select count(*)::integer
        from entities.agent
        where id >= '14000000-0000-4000-8000-000000000000'::uuid
          and id <  '14000000-0000-4000-8000-000000000100'::uuid
    ) = 1,
    'no Rapa Nui people agent was created from the wording'
);

-- Sparse event: no inferred endpoints, parties, location or actor.

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate in (
              'transferred_from',
              'transferred_to',
              'moved_from',
              'moved_to',
              'occurred_at',
              'carried_out_by',
              'transferred_item'
          )
    ),
    'no origin, destination, participant or transfer-party claims exist on the event'
);

-- Museum custody is a direct item claim, not an event recipient.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '34000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'held_by'
          and object_entity_id = '14000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '34000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'located_at'
          and object_entity_id = '24000000-0000-4000-8000-000000000002'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate in ('transferred_to', 'moved_to', 'holding_agent')
          and object_entity_id in (
              '14000000-0000-4000-8000-000000000001'::uuid,
              '24000000-0000-4000-8000-000000000002'::uuid
          )
    ),
    'museum custody is a direct item claim, not an event recipient'
);

-- No ownership, consent, authority, legality or lawful-title predicates.

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id in (
            '34000000-0000-4000-8000-000000000001'::uuid,
            '84000000-0000-4000-8000-000000000001'::uuid
        )
          and predicate in (
              'owned_by',
              'owner',
              'has_owner',
              'lawful_title',
              'legal_status',
              'consent',
              'consented_by',
              'authority',
              'authorised_by',
              'authorized_by'
          )
    ),
    'no ownership, consent, authority, legality or lawful-title predicates exist'
);

-- Missing details can be derived from absent role claims.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_item'
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate in (
              'moved_from',
              'moved_to',
              'carried_out_by',
              'transferred_from',
              'transferred_to'
          )
    ),
    'missing details can be derived from absent role claims'
);

-- Places exist for later evidence without being forced onto the 1952 event.

select ok(
    exists (
        select 1
        from entities.place
        where id = '24000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from entities.place
        where id = '24000000-0000-4000-8000-000000000002'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and object_entity_id = '24000000-0000-4000-8000-000000000001'::uuid
    ),
    'Rapa Nui and La Serena places exist without inventing a 1952 event location'
);

-- Every event claim has evidence.

select is(
    (
        select count(*)::integer
        from (
            select claim.id
            from knowledge.claim as claim
            left join knowledge.claim_evidence as evidence
                on evidence.claim_id = claim.id
            where claim.subject_id = '84000000-0000-4000-8000-000000000001'::uuid
            group by claim.id
            having count(evidence.id) = 0
        ) as claims_without_evidence
    ),
    0,
    'every La Serena event claim has evidence'
);

-- No transferred_item on the provisional event.

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id = '84000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'transferred_item'
    )
    and exists (
        select 1
        from provenance.event
        where id = '84000000-0000-4000-8000-000000000001'::uuid
          and event_kind = 'relocation'
    ),
    'the provisional event uses moved_item with relocation kind rather than transferred_item or transfer kind'
);

select * from finish();
rollback;
