-- Production, findspot and current-location claims for Phase 2 case 07.
--
-- This fixture depends on the Phase 1 Hoa Hakananaiʻa item and British Museum
-- catalogue source, plus the Case 07 Orongo place.
--
-- Claim IDs start at ...110 so they do not collide with Case 07 display-name
-- claims (...100–...108) or the community additions (...090–...094).
--
-- "likely" qualifies the made_at claim via claim evidence. It is not
-- encoded into the predicate name.

begin;

set local lock_timeout = '5s';
set local statement_timeout = '30s';

do $$
begin
    if not exists (
        select 1
        from entities.entity
        where id = '30000000-0000-4000-8000-000000000001'::uuid
          and entity_type = 'item'
    ) then
        raise exception
            'Hoa Hakananaiʻa production fixture requires the Phase 1 item.';
    end if;

    if not exists (
        select 1
        from entities.entity
        where id = '10000000-0000-4000-8000-000000000002'::uuid
          and entity_type = 'agent'
    ) then
        raise exception
            'Hoa Hakananaiʻa production fixture requires the British Museum agent.';
    end if;

    if not exists (
        select 1
        from entities.source
        where id = '40000000-0000-4000-8000-000000000001'::uuid
    ) then
        raise exception
            'Hoa Hakananaiʻa production fixture requires the British Museum catalogue source.';
    end if;

    if not exists (
        select 1
        from knowledge.claim
        where predicate = 'has_name'
          and status = 'active'
          and literal_value ->> 'value' = 'Orongo'
    ) then
        raise exception
            'Hoa Hakananaiʻa production fixture requires the Case 07 Orongo place.';
    end if;
end;
$$;

delete from knowledge.claim_evidence
where id >= '63000000-0000-4000-8000-000000000110'::uuid
  and id <= '63000000-0000-4000-8000-000000000118'::uuid;

delete from knowledge.claim
where id >= '53000000-0000-4000-8000-000000000110'::uuid
  and id <= '53000000-0000-4000-8000-000000000116'::uuid;

delete from entities.place
where id in (
    '23000000-0000-4000-8000-000000000090'::uuid,
    '23000000-0000-4000-8000-000000000091'::uuid
);

delete from entities.entity
where id in (
    '23000000-0000-4000-8000-000000000090'::uuid,
    '23000000-0000-4000-8000-000000000091'::uuid
);

insert into entities.entity (
    id,
    entity_type
)
values
    (
        '23000000-0000-4000-8000-000000000090',
        'place'
    ),
    (
        '23000000-0000-4000-8000-000000000091',
        'place'
    );

insert into entities.place (
    id,
    place_kind
)
values
    (
        '23000000-0000-4000-8000-000000000090',
        'volcano'
    ),
    (
        '23000000-0000-4000-8000-000000000091',
        'gallery'
    );

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
values
    (
        '53000000-0000-4000-8000-000000000110',
        '23000000-0000-4000-8000-000000000090',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'Rano Kao'
        ),
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '53000000-0000-4000-8000-000000000111',
        '23000000-0000-4000-8000-000000000091',
        'has_name',
        jsonb_build_object(
            'type', 'text',
            'value', 'British Museum, Room 24'
        ),
        '10000000-0000-4000-8000-000000000002'
    );

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    asserted_by_agent_id
)
values
    (
        '53000000-0000-4000-8000-000000000112',
        '30000000-0000-4000-8000-000000000001',
        'made_at',
        '23000000-0000-4000-8000-000000000090',
        '10000000-0000-4000-8000-000000000002'
    ),
    (
        '53000000-0000-4000-8000-000000000115',
        '30000000-0000-4000-8000-000000000001',
        'located_at',
        '23000000-0000-4000-8000-000000000091',
        '10000000-0000-4000-8000-000000000002'
    );

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
values (
    '53000000-0000-4000-8000-000000000113',
    '30000000-0000-4000-8000-000000000001',
    'made_during',
    jsonb_build_object(
        'type', 'date_interval',
        'earliest', '1000',
        'latest', '1200',
        'precision', 'year',
        'interpretation', 'approximate_range',
        'verbatim', '1000–1200 (approx)'
    ),
    '10000000-0000-4000-8000-000000000002'
);

with orongo as (
    select claim.subject_id as place_id
    from knowledge.claim as claim
    join entities.entity as entity
      on entity.id = claim.subject_id
     and entity.entity_type = 'place'
    where claim.predicate = 'has_name'
      and claim.status = 'active'
      and claim.literal_value ->> 'value' = 'Orongo'
    order by claim.id
    limit 1
)
insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    object_entity_id,
    asserted_by_agent_id
)
select
    '53000000-0000-4000-8000-000000000114',
    '30000000-0000-4000-8000-000000000001',
    'found_at',
    orongo.place_id,
    '10000000-0000-4000-8000-000000000002'
from orongo;

insert into knowledge.claim (
    id,
    subject_id,
    predicate,
    literal_value,
    asserted_by_agent_id
)
values (
    '53000000-0000-4000-8000-000000000116',
    '40000000-0000-4000-8000-000000000001',
    'has_name',
    jsonb_build_object(
        'type', 'text',
        'value', 'British Museum collection record: Hoa Hakananaiʻa'
    ),
    '10000000-0000-4000-8000-000000000002'
);

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
        '63000000-0000-4000-8000-000000000110',
        '53000000-0000-4000-8000-000000000110',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Production place',
        'Rano Kao'
    ),
    (
        '63000000-0000-4000-8000-000000000111',
        '53000000-0000-4000-8000-000000000111',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Location',
        'Room 24 - Living and Dying'
    ),
    (
        '63000000-0000-4000-8000-000000000112',
        '53000000-0000-4000-8000-000000000112',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Production place',
        'Made in: Rano Kao'
    ),
    (
        '63000000-0000-4000-8000-000000000113',
        '53000000-0000-4000-8000-000000000112',
        '40000000-0000-4000-8000-000000000001',
        'qualifies',
        'Production place',
        'likely'
    ),
    (
        '63000000-0000-4000-8000-000000000114',
        '53000000-0000-4000-8000-000000000113',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Production date',
        '1000 -1200 (approx)'
    ),
    (
        '63000000-0000-4000-8000-000000000115',
        '53000000-0000-4000-8000-000000000114',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Findspot',
        'Found/Acquired: Orongo, ceremonial centre'
    ),
    (
        '63000000-0000-4000-8000-000000000116',
        '53000000-0000-4000-8000-000000000115',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Location',
        'On display (Room 24 - Living and Dying)'
    ),
    (
        '63000000-0000-4000-8000-000000000117',
        '53000000-0000-4000-8000-000000000116',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Catalogue title',
        'Hoa Hakananaiʻa'
    ),
    (
        '63000000-0000-4000-8000-000000000118',
        '50000000-0000-4000-8000-000000000011',
        '40000000-0000-4000-8000-000000000001',
        'supports',
        'Museum / Institution',
        'British Museum'
    );

commit;
