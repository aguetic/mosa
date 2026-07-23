begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select no_plan();

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000112'::uuid
          and subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'made_at'
          and object_entity_id =
              '23000000-0000-4000-8000-000000000090'::uuid
          and asserted_by_agent_id =
              '10000000-0000-4000-8000-000000000002'::uuid
    ),
    'the catalogue reports that Hoa Hakananaiʻa was made at Rano Kao'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '53000000-0000-4000-8000-000000000112'::uuid
          and source_id = '40000000-0000-4000-8000-000000000001'::uuid
          and relationship = 'supports'
          and locator = 'Production place'
    ),
    'the catalogue supports the made_at claim'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '53000000-0000-4000-8000-000000000112'::uuid
          and source_id = '40000000-0000-4000-8000-000000000001'::uuid
          and relationship = 'qualifies'
          and locator = 'Production place'
          and excerpt = 'likely'
    ),
    'the source qualification likely remains attached to the made_at claim'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate in (
            'possibly_made_at',
            'probably_made_at',
            'likely_made_at'
        )
    ),
    0,
    'qualification is not encoded into predicate names'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000113'::uuid
          and subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'made_during'
          and literal_value ->> 'type' = 'date_interval'
          and literal_value ->> 'earliest' = '1000'
          and literal_value ->> 'latest' = '1200'
          and literal_value ->> 'precision' = 'year'
          and literal_value ->> 'interpretation' = 'approximate_range'
    ),
    'the approximate production period remains a structured date interval'
);

select ok(
    exists (
        select 1
        from knowledge.claim as found_at
        join knowledge.claim as place_name
          on place_name.subject_id = found_at.object_entity_id
         and place_name.predicate = 'has_name'
         and place_name.status = 'active'
        where found_at.id = '53000000-0000-4000-8000-000000000114'::uuid
          and found_at.subject_id =
              '30000000-0000-4000-8000-000000000001'::uuid
          and found_at.predicate = 'found_at'
          and place_name.literal_value ->> 'value' = 'Orongo'
    ),
    'Orongo is represented separately as the catalogue findspot'
);

select isnt(
    (
        select object_entity_id
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000112'::uuid
    ),
    (
        select object_entity_id
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000114'::uuid
    ),
    'production place and findspot remain distinct'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000115'::uuid
          and subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'located_at'
          and object_entity_id =
              '23000000-0000-4000-8000-000000000091'::uuid
    ),
    'the current Room 24 display is a direct item location claim'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'held_by'
          and object_entity_id =
              '10000000-0000-4000-8000-000000000002'::uuid
          and status = 'active'
    ),
    'the British Museum remains the recorded current holder'
);

select ok(
    not exists (
        select 1
        from knowledge.claim as movement_origin
        where movement_origin.predicate = 'moved_from'
          and movement_origin.object_entity_id =
              '23000000-0000-4000-8000-000000000090'::uuid
          and movement_origin.subject_id in (
              select item_link.subject_id
              from knowledge.claim as item_link
              where item_link.predicate in (
                  'moved_item',
                  'held_item',
                  'transferred_item'
              )
                and item_link.object_entity_id =
                    '30000000-0000-4000-8000-000000000001'::uuid
                and item_link.status = 'active'
          )
    ),
    'the production place is not inferred as a movement origin'
);

select ok(
    not exists (
        select 1
        from knowledge.claim
        where subject_id = '30000000-0000-4000-8000-000000000001'::uuid
          and predicate in (
              'owned_by',
              'lawfully_held_by',
              'lawfully_acquired_by'
          )
    ),
    'current custody and location do not create ownership or lawful-title claims'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000116'::uuid
          and subject_id = '40000000-0000-4000-8000-000000000001'::uuid
          and predicate = 'has_name'
          and literal_value ->> 'value' =
              'British Museum collection record: Hoa Hakananaiʻa'
    ),
    'the British Museum catalogue source has a readable display name'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '50000000-0000-4000-8000-000000000011'::uuid
          and source_id = '40000000-0000-4000-8000-000000000001'::uuid
          and relationship = 'supports'
    ),
    'held_by the British Museum is also supported by the institutional catalogue'
);

select * from finish();

rollback;
