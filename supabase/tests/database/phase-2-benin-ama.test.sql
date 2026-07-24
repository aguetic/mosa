begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select no_plan();

select is(
    (
        select count(*)::integer
        from entities.external_identifier
        where entity_id = '35000000-0000-4000-8000-000000000001'::uuid
          and namespace = 'british-museum'
          and value = 'Af1898,0115.30'
    ),
    1,
    'the Ama has one stable British Museum identifier'
);

select ok(
    exists (
        select 1
        from knowledge.claim as classification
        join knowledge.claim_evidence as evidence
          on evidence.claim_id = classification.id
        where classification.id =
              '55000000-0000-4000-8000-000000000002'::uuid
          and classification.predicate = 'classified_as'
          and classification.literal_value ->> 'value' = 'Ama'
          and classification.asserted_by_agent_id =
              '15000000-0000-4000-8000-000000000004'::uuid
          and evidence.source_id =
              '45000000-0000-4000-8000-000000000003'::uuid
          and evidence.relationship = 'supports'
    ),
    'Digital Benin directly supports the Edo designation Ama'
);

select ok(
    exists (
        select 1
        from knowledge.claim as classification
        join knowledge.claim_evidence as evidence
          on evidence.claim_id = classification.id
        where classification.id =
              '55000000-0000-4000-8000-000000000003'::uuid
          and classification.predicate = 'classified_as'
          and classification.literal_value ->> 'value' = 'relief plaque'
          and classification.asserted_by_agent_id =
              '10000000-0000-4000-8000-000000000002'::uuid
          and evidence.source_id =
              '45000000-0000-4000-8000-000000000001'::uuid
          and evidence.relationship = 'supports'
    ),
    'the British Museum directly supports the parallel relief plaque classification'
);

select ok(
    (
        select count(distinct asserted_by_agent_id)::integer
        from knowledge.claim
        where id in (
            '55000000-0000-4000-8000-000000000002'::uuid,
            '55000000-0000-4000-8000-000000000003'::uuid
        )
    ) = 2
    and (
        select count(distinct evidence.source_id)::integer
        from knowledge.claim_evidence as evidence
        where evidence.claim_id in (
            '55000000-0000-4000-8000-000000000002'::uuid,
            '55000000-0000-4000-8000-000000000003'::uuid
        )
    ) = 2,
    'Ama and relief plaque classifications have different asserting agents and sources'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '55000000-0000-4000-8000-000000000005'::uuid
          and predicate = 'made_at'
          and object_entity_id =
              '25000000-0000-4000-8000-000000000001'::uuid
    ),
    'the item has a direct made_at claim for Benin City'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '55000000-0000-4000-8000-000000000006'::uuid
          and predicate = 'made_during'
          and literal_value ->> 'precision' = 'century'
          and literal_value ->> 'verbatim' = '16thC–17thC'
    ),
    'the production period remains a structured century-level range'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '35000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'held_by'
          and object_entity_id =
              '10000000-0000-4000-8000-000000000002'::uuid
    ),
    'current British Museum custody is recorded directly on the item'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '35000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'located_at'
    ),
    0,
    'the fixture does not invent a current storage location'
);

select is(
    (
        select count(distinct subject_id)::integer
        from knowledge.claim
        where predicate in ('moved_item', 'transferred_item')
          and object_entity_id =
              '35000000-0000-4000-8000-000000000001'::uuid
          and subject_id >=
              '85000000-0000-4000-8000-000000000000'::uuid
          and subject_id <
              '85000000-0000-4000-8000-000000000100'::uuid
    ),
    4,
    'the item is linked to four separate provenance events'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'moved_from'
          and object_entity_id =
              '25000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'carried_out_by'
          and object_entity_id =
              '15000000-0000-4000-8000-000000000001'::uuid
    ),
    'the February 1897 removal records the palace origin and British force'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
          and literal_value ->> 'earliest' = '1897-02'
          and literal_value ->> 'latest' = '1897-02'
          and literal_value ->> 'precision' = 'month'
    ),
    'the removal preserves February 1897 at month precision'
);

select ok(
    exists (
        select 1
        from knowledge.claim as looting
        join knowledge.claim_evidence as evidence
          on evidence.claim_id = looting.id
        where looting.id = '55000000-0000-4000-8000-000000000034'::uuid
          and looting.predicate = 'described_as'
          and looting.literal_value ->> 'value' = 'looted by British forces'
          and evidence.source_id =
              '45000000-0000-4000-8000-000000000001'::uuid
          and evidence.relationship = 'supports'
          and evidence.excerpt = 'looted by British forces'
    ),
    'looted by British forces is directly supported by the object record'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '55000000-0000-4000-8000-000000000034'::uuid
          and source_id = '45000000-0000-4000-8000-000000000002'::uuid
          and relationship = 'provides_context'
          and excerpt = 'official "spoils of war"'
    ),
    'official spoils of war is provides_context from the contested-objects account on the looting claim'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id >=
              '85000000-0000-4000-8000-000000000000'::uuid
          and subject_id <
              '85000000-0000-4000-8000-000000000100'::uuid
          and predicate = 'described_as'
          and (
              literal_value ->> 'value' ilike '%spoils of war%'
              or literal_value ->> 'value' ilike '%spoils%'
          )
    ),
    0,
    'no separate event-level spoils of war characterisation exists'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'moved_to'
          and object_entity_id =
              '25000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'transferred_to'
          and object_entity_id =
              '15000000-0000-4000-8000-000000000002'::uuid
    ),
    'transport to Britain and transfer into Foreign Office custody are distinct claims'
);

select ok(
    (
        select count(*)::integer
        from knowledge.claim_evidence
        where claim_id in (
            '55000000-0000-4000-8000-000000000040'::uuid,
            '55000000-0000-4000-8000-000000000041'::uuid,
            '55000000-0000-4000-8000-000000000042'::uuid,
            '55000000-0000-4000-8000-000000000043'::uuid,
            '55000000-0000-4000-8000-000000000044'::uuid,
            '55000000-0000-4000-8000-000000000045'::uuid
        )
          and relationship = 'provides_context'
    ) = 6
    and not exists (
        select 1
        from knowledge.claim_evidence
        where claim_id in (
            '55000000-0000-4000-8000-000000000040'::uuid,
            '55000000-0000-4000-8000-000000000041'::uuid,
            '55000000-0000-4000-8000-000000000042'::uuid,
            '55000000-0000-4000-8000-000000000043'::uuid,
            '55000000-0000-4000-8000-000000000044'::uuid,
            '55000000-0000-4000-8000-000000000045'::uuid
        )
          and relationship = 'supports'
    ),
    'Foreign Office movement claims remain group-level provides_context evidence'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate in ('moved_item', 'transferred_item')
          and object_entity_id =
              '35000000-0000-4000-8000-000000000001'::uuid
    ),
    2,
    'the temporary loan records both physical movement and custody transfer'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_from'
          and object_entity_id =
              '15000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'transferred_to'
          and object_entity_id =
              '10000000-0000-4000-8000-000000000002'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'described_as'
          and literal_value ->> 'value' = 'temporary loan'
    ),
    'the 1897 temporary loan has explicit parties and source wording'
);

select ok(
    (
        select count(*)::integer
        from knowledge.claim_evidence
        where claim_id in (
            '55000000-0000-4000-8000-000000000050'::uuid,
            '55000000-0000-4000-8000-000000000051'::uuid,
            '55000000-0000-4000-8000-000000000052'::uuid,
            '55000000-0000-4000-8000-000000000053'::uuid,
            '55000000-0000-4000-8000-000000000054'::uuid,
            '55000000-0000-4000-8000-000000000055'::uuid
        )
          and relationship = 'provides_context'
    ) = 6
    and not exists (
        select 1
        from knowledge.claim_evidence
        where claim_id in (
            '55000000-0000-4000-8000-000000000050'::uuid,
            '55000000-0000-4000-8000-000000000051'::uuid,
            '55000000-0000-4000-8000-000000000052'::uuid,
            '55000000-0000-4000-8000-000000000053'::uuid,
            '55000000-0000-4000-8000-000000000054'::uuid,
            '55000000-0000-4000-8000-000000000055'::uuid
        )
          and relationship = 'supports'
    ),
    'temporary-loan claims remain provisional group-level provides_context evidence'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_item'
          and object_entity_id =
              '35000000-0000-4000-8000-000000000001'::uuid
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'moved_item'
    ),
    'the 1898 gift is a transfer without a second physical movement'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_from'
          and object_entity_id =
              '15000000-0000-4000-8000-000000000003'::uuid
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'transferred_to'
          and object_entity_id =
              '10000000-0000-4000-8000-000000000002'::uuid
    ),
    'the gift records the Secretary of State and British Museum as transfer parties'
);

select ok(
    (
        select count(*)::integer
        from knowledge.claim_evidence
        where claim_id in (
            '55000000-0000-4000-8000-000000000060'::uuid,
            '55000000-0000-4000-8000-000000000061'::uuid,
            '55000000-0000-4000-8000-000000000062'::uuid,
            '55000000-0000-4000-8000-000000000063'::uuid,
            '55000000-0000-4000-8000-000000000064'::uuid
        )
          and relationship = 'supports'
    ) = 5,
    'the 1898 gift is directly supported by this registration acquisition record'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate = 'described_as'
          and literal_value ->> 'value' = 'gift'
          and subject_id >=
              '85000000-0000-4000-8000-000000000000'::uuid
          and subject_id <
              '85000000-0000-4000-8000-000000000100'::uuid
    ),
    1,
    'gift characterises only one Case 09 event'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'described_as'
          and literal_value ->> 'value' = 'gift'
    )
    and not exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'described_as'
          and literal_value ->> 'value' ilike '%gift%'
    ),
    'the 1898 gift wording does not contaminate the 1897 removal'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id >=
              '85000000-0000-4000-8000-000000000000'::uuid
          and subject_id <
              '85000000-0000-4000-8000-000000000100'::uuid
          and predicate = 'preceded_by'
    ),
    0,
    'Case 09 does not store preceded_by event-chain claims'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'occurred_during'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'occurred_during'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'occurred_during'
    )
    and exists (
        select 1
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'occurred_during'
    ),
    'each Case 09 event has its own reported date'
);

select ok(
    (
        select literal_value ->> 'earliest'
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000004'::uuid
          and predicate = 'occurred_during'
    ) = '1898'
    and (
        select literal_value ->> 'earliest'
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000002'::uuid
          and predicate = 'occurred_during'
    ) = '1897'
    and (
        select literal_value ->> 'earliest'
        from knowledge.claim
        where subject_id = '85000000-0000-4000-8000-000000000003'::uuid
          and predicate = 'occurred_during'
    ) = '1897',
    'the 1898 gift is distinguishable by date from the 1897 events'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where subject_id in (
            '85000000-0000-4000-8000-000000000002'::uuid,
            '85000000-0000-4000-8000-000000000003'::uuid
        )
          and predicate = 'occurred_during'
          and literal_value ->> 'earliest' = '1897'
          and literal_value ->> 'latest' = '1897'
    ),
    2,
    'two 1897 events may coexist without a stored total order'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where (
            subject_id = '35000000-0000-4000-8000-000000000001'::uuid
            or subject_id >=
                '85000000-0000-4000-8000-000000000000'::uuid
               and subject_id <
                '85000000-0000-4000-8000-000000000100'::uuid
        )
          and predicate in (
              'owned_by',
              'stolen_item',
              'theft',
              'illegally_removed',
              'lawfully_acquired_by',
              'lawfully_held_by',
              'consented_to',
              'authorised_by',
              'restitution_requested',
              'returned_to',
              'preceded_by',
              'involved'
          )
    ),
    0,
    'the fixture creates no ownership, legality, consent, restitution or event-chain conclusions'
);

select * from finish();

rollback;
