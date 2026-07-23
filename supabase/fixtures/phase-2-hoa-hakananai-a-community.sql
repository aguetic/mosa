-- Direct Rapa Nui evidence for Phase 2 case 07.
--
-- This fixture extends the base Hoa Hakananaiʻa fixture. It adds a source
-- authored by Ma’u Henua and one source-attributed characterisation of the
-- existing 1868 removal event. Repatriation negotiations remain out of scope.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
declare
    removal_event_count integer;
begin
    if not exists (
        select 1
        from entities.entity
        where id = '30000000-0000-4000-8000-000000000001'::uuid
          and entity_type = 'item'
    ) then
        raise exception
            'Direct Rapa Nui evidence fixture requires the Phase 1 Hoa Hakananaiʻa item.';
    end if;

    select count(*)::integer
      into removal_event_count
      from (
          select distinct moved_item.subject_id
          from knowledge.claim as moved_item
          where moved_item.predicate = 'moved_item'
            and moved_item.object_entity_id =
                '30000000-0000-4000-8000-000000000001'::uuid
            and moved_item.status = 'active'
            and exists (
                select 1
                from knowledge.claim as event_date
                where event_date.subject_id = moved_item.subject_id
                  and event_date.predicate = 'occurred_during'
                  and event_date.status = 'active'
                  and event_date.literal_value ->> 'earliest' = '1868'
                  and event_date.literal_value ->> 'latest' = '1868'
            )
      ) as removal_events;

    if removal_event_count <> 1 then
        raise exception
            'Direct Rapa Nui evidence fixture expected exactly one active 1868 Hoa Hakananaiʻa movement event, found %.',
            removal_event_count;
    end if;
end;
$$;

-- Make the extension fixture repeatable.
delete from knowledge.claim_evidence
where id >= '63000000-0000-4000-8000-000000000090'::uuid
  and id <= '63000000-0000-4000-8000-000000000094'::uuid;

delete from knowledge.claim
where id >= '53000000-0000-4000-8000-000000000090'::uuid
  and id <= '53000000-0000-4000-8000-000000000094'::uuid;

delete from entities.source
where id = '43000000-0000-4000-8000-000000000090'::uuid;

delete from entities.agent
where id = '13000000-0000-4000-8000-000000000090'::uuid;

delete from entities.entity
where id in (
    '13000000-0000-4000-8000-000000000090'::uuid,
    '43000000-0000-4000-8000-000000000090'::uuid
);

insert into entities.entity (id, entity_type)
values
    (
        '13000000-0000-4000-8000-000000000090',
        'agent'
    ),
    (
        '43000000-0000-4000-8000-000000000090',
        'source'
    );

insert into entities.agent (id, agent_kind)
values (
    '13000000-0000-4000-8000-000000000090',
    'community'
);

insert into entities.source (
    id,
    source_kind,
    reference,
    retrieved_at
)
values (
    '43000000-0000-4000-8000-000000000090',
    'community_webpage',
    'https://moevarua.com/en/historical-advances-in-repatriation-of-rapanui-heritage/',
    null
);

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    literal_value,
    asserted_by_agent_id
)
values
    (
        '53000000-0000-4000-8000-000000000090',
        '13000000-0000-4000-8000-000000000090',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Ma’u Henua Indigenous Community',
            'language', 'en'
        ),
        '13000000-0000-4000-8000-000000000090'
    ),
    (
        '53000000-0000-4000-8000-000000000091',
        '43000000-0000-4000-8000-000000000090',
        'has_name',
        null,
        jsonb_build_object(
            'type', 'text',
            'value', 'Ma’u Henua report on Hoa Hakananaiʻa repatriation',
            'language', 'en'
        ),
        '13000000-0000-4000-8000-000000000090'
    ),
    (
        '53000000-0000-4000-8000-000000000092',
        '43000000-0000-4000-8000-000000000090',
        'authored_by',
        '13000000-0000-4000-8000-000000000090',
        null,
        '13000000-0000-4000-8000-000000000090'
    ),
    (
        '53000000-0000-4000-8000-000000000093',
        '43000000-0000-4000-8000-000000000090',
        'refers_to',
        '30000000-0000-4000-8000-000000000001',
        null,
        '13000000-0000-4000-8000-000000000090'
    );

with removal_event as (
    select distinct moved_item.subject_id as event_id
    from knowledge.claim as moved_item
    where moved_item.predicate = 'moved_item'
      and moved_item.object_entity_id =
          '30000000-0000-4000-8000-000000000001'::uuid
      and moved_item.status = 'active'
      and exists (
          select 1
          from knowledge.claim as event_date
          where event_date.subject_id = moved_item.subject_id
            and event_date.predicate = 'occurred_during'
            and event_date.status = 'active'
            and event_date.literal_value ->> 'earliest' = '1868'
            and event_date.literal_value ->> 'latest' = '1868'
      )
)
insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
select
    '53000000-0000-4000-8000-000000000094',
    removal_event.event_id,
    'described_as',
    jsonb_build_object(
        'type', 'text',
        'value',
        'Its removal in 1868 was carried out without the genuine consent of the Rapanui people.',
        'language', 'en'
    ),
    '13000000-0000-4000-8000-000000000090'
from removal_event;

insert into knowledge.claim_evidence (
    id,
    claim_id,
    source_id,
    relationship,
    locator,
    excerpt
)
values
    (
        '63000000-0000-4000-8000-000000000090',
        '53000000-0000-4000-8000-000000000090',
        '43000000-0000-4000-8000-000000000090',
        'supports',
        'Author of the report',
        null
    ),
    (
        '63000000-0000-4000-8000-000000000091',
        '53000000-0000-4000-8000-000000000091',
        '43000000-0000-4000-8000-000000000090',
        'supports',
        'Report heading',
        null
    ),
    (
        '63000000-0000-4000-8000-000000000092',
        '53000000-0000-4000-8000-000000000092',
        '43000000-0000-4000-8000-000000000090',
        'supports',
        'Author of the report',
        'Ma’u Henua'
    ),
    (
        '63000000-0000-4000-8000-000000000093',
        '53000000-0000-4000-8000-000000000093',
        '43000000-0000-4000-8000-000000000090',
        'supports',
        'The Moai Hoa Hakananaiʻa — History and Significance',
        null
    ),
    (
        '63000000-0000-4000-8000-000000000094',
        '53000000-0000-4000-8000-000000000094',
        '43000000-0000-4000-8000-000000000090',
        'supports',
        'Frequently asked questions > Why is Rapa Nui requesting the return?',
        'without the genuine consent of the Rapanui people'
    );

commit;
