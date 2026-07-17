begin;

-- One row per claim. Evidence is deliberately excluded so a claim with several
-- evidence links is not duplicated in the canonical claim read model.
create or replace view knowledge.claim_details
with (security_invoker = true)
as
select
    c.id as claim_id,
    c.subject_id,
    subject.working_label as subject_label,
    subject.entity_type as subject_type,
    c.predicate,
    case
        when c.object_entity_id is not null then 'entity'
        else 'literal'
    end as value_kind,
    c.object_entity_id,
    object_entity.working_label as object_entity_label,
    object_entity.entity_type as object_entity_type,
    c.literal_value,
    c.literal_value ->> 'value' as literal_display_value,
    c.literal_value ->> 'language' as literal_language,
    c.asserted_by_agent_id,
    asserted_by.working_label as asserted_by_label,
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
left join entities.entity as object_entity
    on object_entity.id = c.object_entity_id
left join entities.entity as asserted_by
    on asserted_by.id = c.asserted_by_agent_id;

comment on view knowledge.claim_details is
    'One row per claim with display labels. Evidence is available separately through knowledge.claim_evidence_details.';

-- One row per claim/evidence relationship.
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
    source.working_label as source_label,
    ce.relationship,
    ce.locator,
    ce.excerpt,
    ce.notes as evidence_notes,
    ce.created_at as evidence_created_at,
    ce.created_by as evidence_created_by
from knowledge.claim_evidence as ce
join knowledge.claim_details as cd
    on cd.claim_id = ce.claim_id
join entities.entity as source
    on source.id = ce.source_id;

comment on view knowledge.claim_evidence_details is
    'One row per evidence link, including the associated claim and source display labels.';

-- These helpers keep base-entity and subtype creation atomic. They are security
-- invoker functions, so the caller still needs the table privileges and must
-- satisfy the existing RLS policies.
create or replace function entities.create_item(
    p_working_label text,
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
    if nullif(btrim(p_working_label), '') is null then
        raise exception using
            errcode = '22023',
            message = 'working_label must not be blank';
    end if;

    insert into entities.entity (entity_type, working_label, notes)
    values ('item', btrim(p_working_label), p_notes)
    returning id into v_id;

    insert into entities.item (id, item_kind)
    values (v_id, nullif(btrim(p_item_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_agent(
    p_working_label text,
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
    if nullif(btrim(p_working_label), '') is null then
        raise exception using
            errcode = '22023',
            message = 'working_label must not be blank';
    end if;

    insert into entities.entity (entity_type, working_label, notes)
    values ('agent', btrim(p_working_label), p_notes)
    returning id into v_id;

    insert into entities.agent (id, agent_kind)
    values (v_id, nullif(btrim(p_agent_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_place(
    p_working_label text,
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
    if nullif(btrim(p_working_label), '') is null then
        raise exception using
            errcode = '22023',
            message = 'working_label must not be blank';
    end if;

    insert into entities.entity (entity_type, working_label, notes)
    values ('place', btrim(p_working_label), p_notes)
    returning id into v_id;

    insert into entities.place (id, place_kind)
    values (v_id, nullif(btrim(p_place_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_source(
    p_working_label text,
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
    if nullif(btrim(p_working_label), '') is null then
        raise exception using
            errcode = '22023',
            message = 'working_label must not be blank';
    end if;

    if nullif(btrim(p_source_kind), '') is null then
        raise exception using
            errcode = '22023',
            message = 'source_kind must not be blank';
    end if;

    insert into entities.entity (entity_type, working_label, notes)
    values ('source', btrim(p_working_label), p_notes)
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

comment on function entities.create_item(text, text, text) is
    'Atomically creates an item base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_agent(text, text, text) is
    'Atomically creates an agent base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_place(text, text, text) is
    'Atomically creates a place base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_source(text, text, text, timestamptz, text) is
    'Atomically creates a source base entity and its subtype row, returning the generated UUID.';

-- Function execution is opt-in. PUBLIC includes every database role, so revoke
-- that default before granting the application roles explicitly.
revoke execute on function entities.create_item(text, text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_agent(text, text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_place(text, text, text)
    from public, anon, authenticated;
revoke execute on function entities.create_source(text, text, text, timestamptz, text)
    from public, anon, authenticated;

grant execute on function entities.create_item(text, text, text)
    to authenticated, service_role;
grant execute on function entities.create_agent(text, text, text)
    to authenticated, service_role;
grant execute on function entities.create_place(text, text, text)
    to authenticated, service_role;
grant execute on function entities.create_source(text, text, text, timestamptz, text)
    to authenticated, service_role;

revoke all on knowledge.claim_details from public, anon;
revoke all on knowledge.claim_evidence_details from public, anon;
grant select on knowledge.claim_details to authenticated, service_role;
grant select on knowledge.claim_evidence_details to authenticated, service_role;

commit;
