-- Align event display labels with the explorer title projection:
-- Transfer to X when transferred_to is present without transferred_from.

create or replace function entities.entity_display_label(
    p_entity_id uuid
)
returns table (
    display_label text,
    display_label_basis text,
    display_label_claim_id uuid
)
language sql
stable
security invoker
set search_path = ''
as $$
    with entity as (
        select id, entity_type
        from entities.entity
        where id = p_entity_id
    ),
    name_claim as (
        select
            claim.id as claim_id,
            coalesce(
                nullif(btrim(claim.literal_value ->> 'value'), ''),
                nullif(btrim(claim.literal_value ->> 'verbatim'), '')
            ) as label
        from knowledge.claim as claim
        where claim.subject_id = p_entity_id
          and claim.predicate = 'has_name'
          and claim.status = 'active'
          and coalesce(
                nullif(btrim(claim.literal_value ->> 'value'), ''),
                nullif(btrim(claim.literal_value ->> 'verbatim'), '')
              ) is not null
        order by claim.id
        limit 1
    ),
    identifier as (
        select
            identifier.value as label
        from entities.external_identifier as identifier
        where identifier.entity_id = p_entity_id
        order by identifier.namespace, identifier.value, identifier.id
        limit 1
    ),
    source_reference as (
        select
            nullif(btrim(source.reference), '') as label
        from entities.source as source
        where source.id = p_entity_id
    ),
    transferred_from as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'transferred_from'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    transferred_to as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'transferred_to'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    moved_from as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'moved_from'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    moved_to as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'moved_to'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    holding_agent as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'holding_agent'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    occurred_at as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'occurred_at'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    carried_out_by as (
        select object_entity_id
        from knowledge.claim
        where subject_id = p_entity_id
          and predicate = 'carried_out_by'
          and status = 'active'
          and object_entity_id is not null
        order by id
        limit 1
    ),
    related_label as (
        select
            related.id as related_id,
            coalesce(
                (
                    select coalesce(
                        nullif(btrim(claim.literal_value ->> 'value'), ''),
                        nullif(btrim(claim.literal_value ->> 'verbatim'), '')
                    )
                    from knowledge.claim as claim
                    where claim.subject_id = related.id
                      and claim.predicate = 'has_name'
                      and claim.status = 'active'
                    order by claim.id
                    limit 1
                ),
                (
                    select identifier.value
                    from entities.external_identifier as identifier
                    where identifier.entity_id = related.id
                    order by identifier.namespace, identifier.value, identifier.id
                    limit 1
                ),
                initcap(related.entity_type) || ' ' || left(related.id::text, 8)
            ) as label
        from entities.entity as related
    ),
    event_title as (
        select
            case
                when transferred_from.object_entity_id is not null
                     and transferred_to.object_entity_id is not null
                    then 'Transfer from '
                        || (select label from related_label where related_id = transferred_from.object_entity_id)
                        || ' to '
                        || (select label from related_label where related_id = transferred_to.object_entity_id)
                when transferred_to.object_entity_id is not null
                    then 'Transfer to '
                        || (select label from related_label where related_id = transferred_to.object_entity_id)
                when moved_from.object_entity_id is not null
                     and moved_to.object_entity_id is not null
                    then 'Movement from '
                        || (select label from related_label where related_id = moved_from.object_entity_id)
                        || ' to '
                        || (select label from related_label where related_id = moved_to.object_entity_id)
                when moved_to.object_entity_id is not null
                     and moved_from.object_entity_id is null
                    then 'Arrival in '
                        || (select label from related_label where related_id = moved_to.object_entity_id)
                when holding_agent.object_entity_id is not null
                    then 'Held by '
                        || (select label from related_label where related_id = holding_agent.object_entity_id)
                when occurred_at.object_entity_id is not null
                     and carried_out_by.object_entity_id is not null
                    then 'Event at '
                        || (select label from related_label where related_id = occurred_at.object_entity_id)
                        || ' involving '
                        || (select label from related_label where related_id = carried_out_by.object_entity_id)
                when occurred_at.object_entity_id is not null
                    then 'Event at '
                        || (select label from related_label where related_id = occurred_at.object_entity_id)
                else 'Provenance event'
            end as label
        from entity
        left join transferred_from on true
        left join transferred_to on true
        left join moved_from on true
        left join moved_to on true
        left join holding_agent on true
        left join occurred_at on true
        left join carried_out_by on true
        where entity.entity_type = 'event'
    )
    select
        coalesce(
            name_claim.label,
            identifier.label,
            source_reference.label,
            event_title.label,
            initcap(entity.entity_type) || ' ' || left(entity.id::text, 8)
        ) as display_label,
        case
            when name_claim.label is not null then 'has_name'
            when identifier.label is not null then 'external_identifier'
            when source_reference.label is not null then 'source_reference'
            when event_title.label is not null then 'event_summary'
            else 'entity_id'
        end as display_label_basis,
        name_claim.claim_id as display_label_claim_id
    from entity
    left join name_claim on true
    left join identifier on true
    left join source_reference on true
    left join event_title on true;
$$;

comment on function entities.entity_display_label(uuid) is
    'Presentation projection for an entity label. Prefers has_name, then external identifier, then source reference, then an event-summary title, then a technical entity-id fallback. Not a preferred-name model.';
