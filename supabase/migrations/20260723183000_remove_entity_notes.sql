-- Remove general-purpose prose from entities.entity.
-- Domain meaning belongs in attributed claims; claim/evidence notes remain
-- editorial metadata only.

begin;

drop function if exists provenance.create_event(text, text);
drop function if exists entities.create_item(text, text);
drop function if exists entities.create_agent(text, text);
drop function if exists entities.create_place(text, text);
drop function if exists entities.create_source(text, text, timestamptz, text);

alter table entities.entity
    drop column notes;

comment on column knowledge.claim.notes is
    'Editorial modeling note. Explains encoding decisions or data-quality concerns; must not supply domain meaning that belongs in claims.';
comment on column knowledge.claim_evidence.notes is
    'Editorial evidence note. Explains locator limitations, transcription issues or data-quality concerns; must not supply domain meaning.';

create or replace function entities.create_item(
    p_item_kind text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type)
    values ('item')
    returning id into v_id;

    insert into entities.item (id, item_kind)
    values (v_id, nullif(btrim(p_item_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_agent(
    p_agent_kind text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type)
    values ('agent')
    returning id into v_id;

    insert into entities.agent (id, agent_kind)
    values (v_id, nullif(btrim(p_agent_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_place(
    p_place_kind text default null
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_id uuid;
begin
    insert into entities.entity (entity_type)
    values ('place')
    returning id into v_id;

    insert into entities.place (id, place_kind)
    values (v_id, nullif(btrim(p_place_kind), ''));

    return v_id;
end;
$$;

create or replace function entities.create_source(
    p_source_kind text,
    p_reference text default null,
    p_retrieved_at timestamptz default null
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

    insert into entities.entity (entity_type)
    values ('source')
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
    p_event_kind text default 'unknown'
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

    insert into entities.entity (entity_type)
    values ('event')
    returning id into v_id;

    insert into provenance.event (id, event_kind)
    values (v_id, p_event_kind);

    return v_id;
end;
$$;

comment on function entities.create_item(text) is
    'Atomically creates an item base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_agent(text) is
    'Atomically creates an agent base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_place(text) is
    'Atomically creates a place base entity and its subtype row, returning the generated UUID.';
comment on function entities.create_source(text, text, timestamptz) is
    'Atomically creates a source base entity and its subtype row, returning the generated UUID.';
comment on function provenance.create_event(text) is
    'Atomically creates an event base entity and provenance subtype row.';

revoke execute on function entities.create_item(text)
    from public, anon, authenticated;
revoke execute on function entities.create_agent(text)
    from public, anon, authenticated;
revoke execute on function entities.create_place(text)
    from public, anon, authenticated;
revoke execute on function entities.create_source(text, text, timestamptz)
    from public, anon, authenticated;
revoke execute on function provenance.create_event(text)
    from public, anon, authenticated;

grant execute on function entities.create_item(text)
    to authenticated, service_role;
grant execute on function entities.create_agent(text)
    to authenticated, service_role;
grant execute on function entities.create_place(text)
    to authenticated, service_role;
grant execute on function entities.create_source(text, text, timestamptz)
    to authenticated, service_role;
grant execute on function provenance.create_event(text)
    to authenticated, service_role;

commit;
