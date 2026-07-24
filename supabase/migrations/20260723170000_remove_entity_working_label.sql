-- Remove stored operational working labels. Display labels become projections
-- from attributed has_name claims, external identifiers, source references,
-- and (for events) claim-derived titles.

begin;

-- Dependents must go before the column.
drop view if exists knowledge.claim_evidence_details;
drop view if exists knowledge.claim_details;

drop function if exists provenance.create_event(text, text, text);
drop function if exists entities.create_item(text, text, text);
drop function if exists entities.create_agent(text, text, text);
drop function if exists entities.create_place(text, text, text);
drop function if exists entities.create_source(text, text, text, timestamptz, text);

drop index if exists entities.entity_working_label_idx;

alter table entities.entity
    drop column working_label;

-- Presentation projection for entity labels. This is not a preferred-name model.
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

create or replace view entities.entity_display
with (security_invoker = true)
as
select
    entity.id,
    entity.entity_type,
    display.display_label,
    display.display_label_basis,
    display.display_label_claim_id
from entities.entity as entity
cross join lateral entities.entity_display_label(entity.id) as display;

comment on function entities.entity_display_label(uuid) is
    'Presentation projection for an entity label. Prefers has_name, then external identifier, then source reference, then an event-summary title, then a technical entity-id fallback. Not a preferred-name model.';
comment on view entities.entity_display is
    'One row per entity with a derived display label and the basis used to select it.';

create or replace view knowledge.claim_details
with (security_invoker = true)
as
select
    c.id as claim_id,
    c.subject_id,
    subject_display.display_label as subject_label,
    subject.entity_type as subject_type,
    c.predicate,
    case
        when c.object_entity_id is not null then 'entity'
        else 'literal'
    end as value_kind,
    c.object_entity_id,
    object_display.display_label as object_entity_label,
    object_entity.entity_type as object_entity_type,
    c.literal_value,
    c.literal_value ->> 'value' as literal_display_value,
    c.literal_value ->> 'language' as literal_language,
    c.asserted_by_agent_id,
    asserted_by_display.display_label as asserted_by_label,
    c.status,
    c.supersedes_claim_id,
    c.notes,
    c.created_at,
    c.created_by,
    c.updated_at,
    c.updated_by
from knowledge.claim as c
join entities.entity as subject
    on subject.id = c.subject_id
join entities.entity_display as subject_display
    on subject_display.id = c.subject_id
left join entities.entity as object_entity
    on object_entity.id = c.object_entity_id
left join entities.entity_display as object_display
    on object_display.id = c.object_entity_id
left join entities.entity_display as asserted_by_display
    on asserted_by_display.id = c.asserted_by_agent_id;

comment on view knowledge.claim_details is
    'One row per claim with derived display labels. Evidence is available separately through knowledge.claim_evidence_details.';

create or replace view knowledge.claim_evidence_details
with (security_invoker = true)
as
select
    ce.id as claim_evidence_id,
    ce.claim_id,
    cd.subject_id,
    cd.subject_label,
    cd.subject_type,
    cd.predicate,
    cd.value_kind,
    cd.object_entity_id,
    cd.object_entity_label,
    cd.object_entity_type,
    cd.literal_value,
    cd.literal_display_value,
    cd.literal_language,
    cd.asserted_by_agent_id,
    cd.asserted_by_label,
    cd.status as claim_status,
    ce.source_id,
    source_display.display_label as source_label,
    ce.relationship,
    ce.locator,
    ce.excerpt,
    ce.notes as evidence_notes,
    ce.created_at as evidence_created_at,
    ce.created_by as evidence_created_by
from knowledge.claim_evidence as ce
join knowledge.claim_details as cd
    on cd.claim_id = ce.claim_id
join entities.entity_display as source_display
    on source_display.id = ce.source_id;

comment on view knowledge.claim_evidence_details is
    'One row per evidence link, including the associated claim and derived source display labels.';

create or replace function entities.create_item(
    p_item_kind text default null,
    p_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type, notes)
    values ('item', p_notes)
    returning id into v_id;

    insert into entities.item (id, item_kind)
    values (v_id, nullif(btrim(p_item_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_agent(
    p_agent_kind text default null,
    p_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type, notes)
    values ('agent', p_notes)
    returning id into v_id;

    insert into entities.agent (id, agent_kind)
    values (v_id, nullif(btrim(p_agent_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_place(
    p_place_kind text default null,
    p_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type, notes)
    values ('place', p_notes)
    returning id into v_id;

    insert into entities.place (id, place_kind)
    values (v_id, nullif(btrim(p_place_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_source(
    p_source_kind text,
    p_reference text default null,
    p_retrieved_at timestamptz default null,
    p_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    if nullif(btrim(p_source_kind), '') is null then
        raise exception using
            errcode = '22023',
            message = 'source_kind must not be blank';
    end if;

    insert into entities.entity (entity_type, notes)
    values ('source', p_notes)
    returning id into v_id;

    insert into entities.source (id, source_kind, reference, retrieved_at)
    values (
        v_id,
        btrim(p_source_kind),
        nullif(btrim(p_reference), ''),
        p_retrieved_at
    );

    return v_id;
end;
$$;

create or replace function provenance.create_event(
    p_event_kind text default 'unknown',
    p_notes text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    if p_event_kind is null
       or p_event_kind not in ('transfer', 'relocation', 'unknown') then
        raise exception using
            errcode = '22023',
            message = 'event_kind must be transfer, relocation or unknown';
    end if;

    insert into entities.entity (entity_type, notes)
    values ('event', p_notes)
    returning id into v_id;

    insert into provenance.event (id, event_kind)
    values (v_id, p_event_kind);

    return v_id;
end;
$$;

comment on function entities.create_item(text, text) is
    'Atomically creates an item base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_agent(text, text) is
    'Atomically creates an agent base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_place(text, text) is
    'Atomically creates a place base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_source(text, text, timestamptz, text) is
    'Atomically creates a source base entity and its subtype row, returning the generated UUID.';
comment on function provenance.create_event(text, text) is
    'Atomically creates an event base entity and provenance subtype row.';

revoke execute on function entities.create_item(text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_agent(text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_place(text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_source(text, text, timestamptz, text)
    from public, anon, authenticated;
revoke execute on function provenance.create_event(text, text)
    from public, anon, authenticated;
revoke execute on function entities.entity_display_label(uuid)
    from public, anon;

grant execute on function entities.create_item(text, text)
    to authenticated, service_role;
grant execute on function entities.create_agent(text, text)
    to authenticated, service_role;
grant execute on function entities.create_place(text, text)
    to authenticated, service_role;
grant execute on function entities.create_source(text, text, timestamptz, text)
    to authenticated, service_role;
grant execute on function provenance.create_event(text, text)
    to authenticated, service_role;
grant execute on function entities.entity_display_label(uuid)
    to authenticated, service_role;

revoke all on knowledge.claim_details from public, anon;
revoke all on knowledge.claim_evidence_details from public, anon;
revoke all on entities.entity_display from public, anon;
grant select on knowledge.claim_details to authenticated, service_role;
grant select on knowledge.claim_evidence_details to authenticated, service_role;
grant select on entities.entity_display to authenticated, service_role;

commit;
