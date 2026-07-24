begin;

create schema if not exists provenance;

-- Events share the entity identity space so existing claims and evidence can
-- describe them without introducing a second assertion system.
alter table entities.entity
    drop constraint entity_entity_type_check;

alter table entities.entity
    add constraint entity_entity_type_check
    check (
        entity_type in (
            'item',
            'agent',
            'place',
            'source',
            'event'
        )
    );

create table provenance.event (
    id uuid primary key
        references entities.entity(id)
        on delete cascade,
    -- Operational grouping only. Source wording such as "collected",
    -- "stolen", "gift" or "deposited" remains in attributed claims.
    event_kind text not null
        check (
            event_kind in (
                'transfer',
                'relocation',
                'unknown'
            )
        )
);

create index event_kind_idx
    on provenance.event (event_kind);

create trigger enforce_event_entity_type
before insert or update on provenance.event
for each row
execute function entities.enforce_entity_subtype('event');

create or replace function provenance.create_event(
    p_working_label text,
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
    if nullif(btrim(p_working_label), '') is null then
        raise exception using
            errcode = '22023',
            message = 'working_label must not be blank';
    end if;

    if p_event_kind is null
       or p_event_kind not in ('transfer', 'relocation', 'unknown') then
        raise exception using
            errcode = '22023',
            message = 'event_kind must be transfer, relocation or unknown';
    end if;

    insert into entities.entity (entity_type, working_label, notes)
    values ('event', btrim(p_working_label), p_notes)
    returning id into v_id;

    insert into provenance.event (id, event_kind)
    values (v_id, p_event_kind);

    return v_id;
end;
$$;

comment on schema provenance is
    'Stable event anchors for sourced, incomplete and competing provenance accounts.';
comment on table provenance.event is
    'Minimal provenance event subtype. Event details remain attributed claims with evidence.';
comment on column provenance.event.event_kind is
    'Operational grouping only; it is not the historical or legal characterisation of the event.';
comment on function provenance.create_event(text, text, text) is
    'Atomically creates an event base entity and provenance subtype row.';

revoke all on schema provenance from anon;
grant usage on schema provenance to authenticated, service_role;

grant select, insert, update, delete
on all tables in schema provenance
to authenticated, service_role;

revoke execute on function provenance.create_event(text, text, text)
    from public, anon, authenticated;
grant execute on function provenance.create_event(text, text, text)
    to authenticated, service_role;

alter default privileges for role postgres
in schema provenance
grant select, insert, update, delete
on tables to authenticated, service_role;

alter table provenance.event enable row level security;

create policy "authenticated project access"
on provenance.event
for all
to authenticated
using (true)
with check (true);

commit;
