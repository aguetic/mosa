begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select no_plan();

select is(
    (
        select count(*)::integer
        from entities.entity
        where id = '13000000-0000-4000-8000-000000000090'::uuid
          and entity_type = 'agent'
    ),
    1,
    'Ma’u Henua exists as a distinct community agent'
);

select is(
    (
        select count(*)::integer
        from entities.source
        where id = '43000000-0000-4000-8000-000000000090'::uuid
          and source_kind = 'community_webpage'
    ),
    1,
    'the direct Ma’u Henua webpage exists as a source'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000092'::uuid
          and subject_id = '43000000-0000-4000-8000-000000000090'::uuid
          and predicate = 'authored_by'
          and object_entity_id =
              '13000000-0000-4000-8000-000000000090'::uuid
          and asserted_by_agent_id =
              '13000000-0000-4000-8000-000000000090'::uuid
    ),
    'the community source is attributed to Ma’u Henua'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000093'::uuid
          and subject_id = '43000000-0000-4000-8000-000000000090'::uuid
          and predicate = 'refers_to'
          and object_entity_id =
              '30000000-0000-4000-8000-000000000001'::uuid
    ),
    'the community source refers to the stable Hoa Hakananaiʻa item'
);

select ok(
    exists (
        select 1
        from knowledge.claim
        where id = '53000000-0000-4000-8000-000000000094'::uuid
          and predicate = 'described_as'
          and asserted_by_agent_id =
              '13000000-0000-4000-8000-000000000090'::uuid
          and literal_value ->> 'value' ilike
              '%without the genuine consent of the Rapanui people%'
    ),
    'Ma’u Henua directly characterises the existing removal event'
);

select ok(
    exists (
        select 1
        from knowledge.claim_evidence
        where claim_id = '53000000-0000-4000-8000-000000000094'::uuid
          and source_id = '43000000-0000-4000-8000-000000000090'::uuid
          and relationship = 'supports'
    ),
    'the direct Ma’u Henua characterisation uses supporting community evidence'
);

select ok(
    exists (
        select 1
        from knowledge.claim as direct_characterisation
        join knowledge.claim as indirect_characterisation
          on indirect_characterisation.subject_id =
             direct_characterisation.subject_id
         and indirect_characterisation.id <>
             direct_characterisation.id
         and indirect_characterisation.predicate = 'described_as'
         and indirect_characterisation.status = 'active'
        join knowledge.claim_evidence as indirect_evidence
          on indirect_evidence.claim_id = indirect_characterisation.id
        where direct_characterisation.id =
              '53000000-0000-4000-8000-000000000094'::uuid
          and indirect_evidence.source_id =
              '40000000-0000-4000-8000-000000000002'::uuid
          and indirect_evidence.relationship = 'mentions'
    ),
    'direct community evidence and an indirect Paula-note characterisation coexist on the same event'
);

select is(
    (
        select count(*)::integer
        from knowledge.claim
        where predicate in (
            'consented_to',
            'consent_status',
            'authorised_by',
            'lawfully_removed',
            'illegally_removed'
        )
          and (
              subject_id = (
                  select subject_id
                  from knowledge.claim
                  where id =
                      '53000000-0000-4000-8000-000000000094'::uuid
              )
              or object_entity_id =
                  '30000000-0000-4000-8000-000000000001'::uuid
          )
    ),
    0,
    'the source characterisation does not create canonical consent, authority or legality predicates'
);

select is(
    (
        select count(distinct moved_item.subject_id)::integer
        from knowledge.claim as moved_item
        where moved_item.predicate = 'moved_item'
          and moved_item.object_entity_id =
              '30000000-0000-4000-8000-000000000001'::uuid
          and exists (
              select 1
              from knowledge.claim as event_date
              where event_date.subject_id = moved_item.subject_id
                and event_date.predicate = 'occurred_during'
                and event_date.literal_value ->> 'earliest' = '1868'
                and event_date.literal_value ->> 'latest' = '1868'
          )
    ),
    1,
    'adding a direct community source does not create a second 1868 removal event'
);

select * from finish();

rollback;
