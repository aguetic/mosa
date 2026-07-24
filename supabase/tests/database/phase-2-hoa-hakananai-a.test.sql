begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(22);

-- Stable Phase 1 item identity and catalogue identifier.

select ok(
    exists (
        select 1
        from entities.item as item
        join entities.entity as entity on entity.id = item.id
        where item.id = '30000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from entities.external_identifier
        where entity_id = '30000000-0000-4000-8000-000000000001'::uuid
          and value = 'Oc1869,1005.1'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'has_name'
          and literal_value ->> 'value' = 'Hoa Hakananaiʻa'
    ),
    'Hoa Hakananaiʻa has one stable item identity with catalogue Oc1869,1005.1'
);

-- Exactly four Case 07 event anchors.

select is(
    (
        select count(*)::integer
        from provenance.event
        where id between
            '83000000-0000-4000-8000-000000000001'::uuid
            and
            '83000000-0000-4000-8000-000000000004'::uuid
    ),
    4,
    'exactly four Case 07 event anchors exist'
);

-- 1868 removal exists once with Orongo, expedition and 1868.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_item'
          and object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
          and status = 'active'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_at'
          and object_entity_id = '23000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '13000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1868'
    )
    and (
        select count(*)::integer
        from provenance.event as event
        join knowledge.claim as moved
            on moved.subject_id = event.id
           and moved.predicate = 'moved_item'
           and moved.object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
        join knowledge.claim as during
            on during.subject_id = event.id
           and during.predicate = 'occurred_during'
           and during.literal_value ->> 'verbatim' = '1868'
        join knowledge.claim as at_place
            on at_place.subject_id = event.id
           and at_place.predicate = 'occurred_at'
           and at_place.object_entity_id = '23000000-0000-4000-8000-000000000001'::uuid
        where event.id between
            '83000000-0000-4000-8000-000000000001'::uuid
            and
            '83000000-0000-4000-8000-000000000004'::uuid
    ) = 1,
    'the 1868 removal event exists once with Orongo, expedition and 1868'
);

-- Multiple independently attributed described_as claims; none as event title/kind.

select ok(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and status = 'active'
    ) >= 2
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and asserted_by_agent_id = '10000000-0000-4000-8000-000000000002'::uuid
          and literal_value ->> 'value' = 'removed from original location'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and asserted_by_agent_id = '10000000-0000-4000-8000-000000000002'::uuid
          and literal_value ->> 'value' = 'collected'
    ),
    'the removal event has multiple independently attributed described_as claims'
);

select ok(
    not exists (
        select 1
        from provenance.event
        where id = '83000000-0000-4000-8000-000000000001'::uuid
          and event_kind in ('theft', 'collection', 'removal', 'stolen', 'collected')
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'has_name'
    ),
    'no description is stored as the event title or event kind'
);

-- Transport is separate and uses moved_via.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_item'
          and object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_from'
          and object_entity_id = '23000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_to'
          and object_entity_id = '23000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_via'
          and object_entity_id = '33000000-0000-4000-8000-000000000001'::uuid
    ),
    'transport is a separate event using moved_via HMS Topaze'
);

select ok(
    exists (
        select 1
        from entities.item
        where id = '33000000-0000-4000-8000-000000000001'::uuid
          and item_kind = 'vessel'
    )
    and exists (
        select 1
        from entities.agent
        where id = '13000000-0000-4000-8000-000000000001'::uuid
    )
    and '33000000-0000-4000-8000-000000000001'::uuid
        <> '13000000-0000-4000-8000-000000000001'::uuid
    and not exists (
        select 1
        from entities.agent
        where id = '33000000-0000-4000-8000-000000000001'::uuid
    ),
    'HMS Topaze and the expedition are distinct entities'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '33000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'commanded_by'
          and object_entity_id = '13000000-0000-4000-8000-000000000002'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '13000000-0000-4000-8000-000000000002'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '83000000-0000-4000-8000-000000000001'::uuid
            and
            '83000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '33000000-0000-4000-8000-000000000001'::uuid
    ),
    'HMS Topaze has commanded_by Richard Ashmore Powell and is not an acting agent'
);

-- Admiralty and Queen-to-Museum transfers remain separate; use transferred_item.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_item'
          and object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id = '13000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '13000000-0000-4000-8000-000000000004'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'moved_item'
    ),
    'Admiralty-to-Queen event uses transferred_item and is not a movement'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_item'
          and object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_from'
          and object_entity_id = '13000000-0000-4000-8000-000000000004'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_to'
          and object_entity_id = '10000000-0000-4000-8000-000000000002'::uuid
    )
    and '83000000-0000-4000-8000-000000000003'::uuid
        <> '83000000-0000-4000-8000-000000000004'::uuid,
    'Queen-to-Museum transfer is a separate transferred_item event'
);

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id in (
            '83000000-0000-4000-8000-000000000003'::uuid,
            '83000000-0000-4000-8000-000000000004'::uuid
        )
          and predicate = 'moved_item'
    ),
    'non-physical transfer events do not use moved_item'
);

-- Current custody is a direct item claim.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'held_by'
          and object_entity_id = '10000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'located_at'
          and object_entity_id = '20000000-0000-4000-8000-000000000001'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id between
            '83000000-0000-4000-8000-000000000001'::uuid
            and
            '83000000-0000-4000-8000-000000000004'::uuid
          and predicate in ('held_item', 'holding_agent')
    ),
    'current custody is a direct held_by claim, not a provenance holding event'
);

-- No involved, preceded_by, ownership, legality or consent claims.

select ok(
    not exists (
        select 1
        from knowledge.claim
        where (
            subject_id between
                '83000000-0000-4000-8000-000000000001'::uuid
                and
                '83000000-0000-4000-8000-000000000004'::uuid
            or subject_id = '30000000-0000-4000-8000-000000000001'::uuid
            or object_entity_id = '30000000-0000-4000-8000-000000000001'::uuid
            or subject_id = '33000000-0000-4000-8000-000000000001'::uuid
        )
          and predicate in (
              'involved',
              'preceded_by',
              'owned_by',
              'lawfully_acquired_by',
              'lawfully_held_by',
              'consented_to_by',
              'consented_by',
              'authorised_by'
          )
    ),
    'no involved, preceded_by, ownership, legality, authority or consent claims exist'
);

-- Institutional characterisations use supports; indirect community uses mentions.

select ok(
    exists (
        select 1
        from knowledge.claim as claim
        join knowledge.claim_evidence as evidence
            on evidence.claim_id = claim.id
           and evidence.relationship = 'supports'
           and evidence.source_id = '40000000-0000-4000-8000-000000000001'::uuid
        where claim.subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and claim.predicate = 'described_as'
          and claim.asserted_by_agent_id = '10000000-0000-4000-8000-000000000002'::uuid
    ),
    'direct institutional characterisations use supports'
);

select ok(
    exists (
        select 1
        from knowledge.claim as claim
        join knowledge.claim_evidence as evidence
            on evidence.claim_id = claim.id
           and evidence.relationship = 'mentions'
           and evidence.source_id = '40000000-0000-4000-8000-000000000002'::uuid
        where claim.subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and claim.predicate = 'described_as'
          and claim.asserted_by_agent_id = '13000000-0000-4000-8000-000000000005'::uuid
          and claim.literal_value ->> 'value' = 'taken from Rapa Nui'
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and literal_value ->> 'value' ilike '%stolen%'
    ),
    'indirect community characterisation uses Paula-note mentions without inventing a stolen claim'
);

-- Every substantive event claim has evidence.

select is(
    (
        select count(*)::integer
        from (
            select claim.id
            from knowledge.claim as claim
            left join knowledge.claim_evidence as evidence
                on evidence.claim_id = claim.id
            where claim.subject_id between
                '83000000-0000-4000-8000-000000000001'::uuid
                and
                '83000000-0000-4000-8000-000000000004'::uuid
            group by claim.id
            having count(evidence.id) = 0
        ) as claims_without_evidence
    ),
    0,
    'every Case 07 event claim has evidence'
);

-- Discovery predicates: transfers are discoverable via transferred_item.

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_item'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_item'
    ),
    'transfer events identify the item through transferred_item'
);

select ok(
    (
        select count(distinct literal_value ->> 'value')::integer
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and status = 'active'
    ) >= 2,
    'removal characterisations include more than one distinct description value'
);

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_from'
    ),
    'Admiralty presentation does not invent transferred_from'
);

select is(
    (
        select display_label
        from entities.entity_display_label('83000000-0000-4000-8000-000000000003'::uuid)
    ),
    'Transfer to Queen Victoria',
    'database display label matches Transfer to Queen Victoria without transferred_from'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '83000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'verbatim' = '1868–1869'
    ),
    'transport preserves the 1868–1869 date range'
);

select ok(
    not exists (
        select 1
        from provenance.event
        where id = '83000000-0000-4000-8000-000000000005'::uuid
    ),
    'no current-custody or display event is invented'
);

select * from finish();
rollback;
