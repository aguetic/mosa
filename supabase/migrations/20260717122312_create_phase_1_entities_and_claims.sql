-- ============================================================
-- MoSA Phase 1: entities, claims and evidence
-- ============================================================

create schema if not exists entities;
create schema if not exists knowledge;

-- ============================================================
-- Shared entity identity
-- ============================================================

create table entities.entity (
    id uuid primary key default gen_random_uuid(),
    entity_type text not null
        check (
            entity_type in (
                'item',
                'agent',
                'place',
                'source'
            )
        ),
    -- Operational interface label only. It is not an authoritative
    -- or culturally preferred name.
    working_label text not null
        check (length(btrim(working_label)) > 0),
    notes text,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    updated_at timestamptz not null default now(),
    updated_by uuid references auth.users(id) on delete set null
);

-- ============================================================
-- Entity subtypes
-- ============================================================

create table entities.item (
    id uuid primary key
        references entities.entity(id)
        on delete cascade,
    -- Lightweight operational attribute only.
    -- Examples: artefact, fragment, assemblage,
    -- ancestral_remains, replica, unknown.
    item_kind text
);

create table entities.agent (
    id uuid primary key
        references entities.entity(id)
        on delete cascade,
    -- Examples: person, organisation, community,
    -- family, expedition, government_body, unknown.
    agent_kind text
);

create table entities.place (
    id uuid primary key
        references entities.entity(id)
        on delete cascade,
    -- Examples: island, settlement, site, building,
    -- port, region, unknown.
    place_kind text
);

create table entities.source (
    id uuid primary key
        references entities.entity(id)
        on delete cascade,
    -- Examples: institutional_record, webpage, spreadsheet,
    -- book, letter, interview, photograph, database_export.
    source_kind text not null
        check (length(btrim(source_kind)) > 0),
    -- URL, archival reference, bibliographic citation,
    -- Supabase Storage path or other locator.
    reference text,
    retrieved_at timestamptz
);

-- ============================================================
-- External identifiers
-- ============================================================

create table entities.external_identifier (
    id uuid primary key default gen_random_uuid(),
    entity_id uuid not null
        references entities.entity(id)
        on delete cascade,
    -- The assigning system or institution.
    -- Examples: british-museum, wikidata, mosa-legacy.
    namespace text not null
        check (length(btrim(namespace)) > 0),
    value text not null
        check (length(btrim(value)) > 0),
    -- Optional source establishing or displaying this identifier.
    source_id uuid
        references entities.source(id)
        on delete set null,
    created_at timestamptz not null default now(),
    unique (namespace, value)
);

-- ============================================================
-- Claims
-- ============================================================

create table knowledge.claim (
    id uuid primary key default gen_random_uuid(),
    -- Any item, agent, place or source may be the subject.
    subject_id uuid not null
        references entities.entity(id)
        on delete restrict,
    -- Initially plain text, for example:
    -- has_name, made_of, refers_to, associated_with_place.
    predicate text not null
        check (length(btrim(predicate)) > 0),
    -- A claim value is either another entity...
    object_entity_id uuid
        references entities.entity(id)
        on delete restrict,
    -- ...or a structured literal.
    literal_value jsonb,
    -- The historical, institutional or community agent represented
    -- as making the assertion. This is not necessarily the MoSA user
    -- who entered it.
    asserted_by_agent_id uuid
        references entities.agent(id)
        on delete set null,
    -- This is revision history, not a formal review workflow.
    status text not null default 'active'
        check (
            status in (
                'active',
                'superseded',
                'withdrawn'
            )
        ),
    supersedes_claim_id uuid
        references knowledge.claim(id)
        on delete set null,
    notes text,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    updated_at timestamptz not null default now(),
    updated_by uuid references auth.users(id) on delete set null,
    constraint claim_has_exactly_one_value
        check (
            num_nonnulls(
                object_entity_id,
                literal_value
            ) = 1
        ),
    constraint claim_literal_is_an_object
        check (
            literal_value is null
            or jsonb_typeof(literal_value) = 'object'
        ),
    constraint claim_does_not_supersede_itself
        check (
            supersedes_claim_id is null
            or supersedes_claim_id <> id
        )
);

-- ============================================================
-- Claim evidence
-- ============================================================

create table knowledge.claim_evidence (
    id uuid primary key default gen_random_uuid(),
    claim_id uuid not null
        references knowledge.claim(id)
        on delete cascade,
    source_id uuid not null
        references entities.source(id)
        on delete restrict,
    relationship text not null
        check (
            relationship in (
                'supports',
                'contradicts',
                'qualifies',
                'mentions',
                'provides_context'
            )
        ),
    -- Examples:
    -- "Materials field"
    -- "Sheet 1, row 24, column G"
    -- "Page 42, paragraph 3"
    -- "00:14:22–00:15:10"
    locator text not null
        check (length(btrim(locator)) > 0),
    excerpt text,
    notes text,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    unique (
        claim_id,
        source_id,
        relationship,
        locator
    )
);

-- ============================================================
-- Basic indexes
-- ============================================================

create index entity_type_idx
    on entities.entity (entity_type);

create index entity_working_label_idx
    on entities.entity (working_label);

create index external_identifier_entity_idx
    on entities.external_identifier (entity_id);

create index claim_subject_idx
    on knowledge.claim (subject_id);

create index claim_predicate_idx
    on knowledge.claim (predicate);

create index claim_object_entity_idx
    on knowledge.claim (object_entity_id)
    where object_entity_id is not null;

create index claim_asserted_by_idx
    on knowledge.claim (asserted_by_agent_id)
    where asserted_by_agent_id is not null;

create index claim_evidence_claim_idx
    on knowledge.claim_evidence (claim_id);

create index claim_evidence_source_idx
    on knowledge.claim_evidence (source_id);

-- ============================================================
-- Keep updated_at current
-- ============================================================

create or replace function entities.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger set_entity_updated_at
before update on entities.entity
for each row
execute function entities.set_updated_at();

create trigger set_claim_updated_at
before update on knowledge.claim
for each row
execute function entities.set_updated_at();

-- ============================================================
-- Ensure subtype tables match entity.entity_type
-- ============================================================

create or replace function entities.enforce_entity_subtype()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
    actual_type text;
begin
    select e.entity_type
      into actual_type
      from entities.entity e
     where e.id = new.id;

    if actual_type is null then
        raise exception
            'No base entity exists for id %',
            new.id;
    end if;

    if actual_type <> tg_argv[0] then
        raise exception
            'Entity % has type %, but this table requires type %',
            new.id,
            actual_type,
            tg_argv[0];
    end if;

    return new;
end;
$$;

create trigger enforce_item_entity_type
before insert or update on entities.item
for each row
execute function entities.enforce_entity_subtype('item');

create trigger enforce_agent_entity_type
before insert or update on entities.agent
for each row
execute function entities.enforce_entity_subtype('agent');

create trigger enforce_place_entity_type
before insert or update on entities.place
for each row
execute function entities.enforce_entity_subtype('place');

create trigger enforce_source_entity_type
before insert or update on entities.source
for each row
execute function entities.enforce_entity_subtype('source');

-- ============================================================
-- Permissions
--
-- Phase 1 is private. All signed-in project users may currently
-- read and edit all research records. Anonymous users receive no
-- access. This can be made more granular later.
-- ============================================================

revoke all on schema entities from anon;
revoke all on schema knowledge from anon;

grant usage on schema entities, knowledge
to authenticated, service_role;

grant select, insert, update, delete
on all tables in schema entities
to authenticated, service_role;

grant select, insert, update, delete
on all tables in schema knowledge
to authenticated, service_role;

grant execute
on function entities.set_updated_at()
to authenticated, service_role;

grant execute
on function entities.enforce_entity_subtype()
to authenticated, service_role;

alter default privileges for role postgres
in schema entities
grant select, insert, update, delete
on tables to authenticated, service_role;

alter default privileges for role postgres
in schema knowledge
grant select, insert, update, delete
on tables to authenticated, service_role;

-- ============================================================
-- Row-level security
-- ============================================================

alter table entities.entity enable row level security;
alter table entities.item enable row level security;
alter table entities.agent enable row level security;
alter table entities.place enable row level security;
alter table entities.source enable row level security;
alter table entities.external_identifier enable row level security;
alter table knowledge.claim enable row level security;
alter table knowledge.claim_evidence enable row level security;

create policy "authenticated project access"
on entities.entity
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on entities.item
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on entities.agent
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on entities.place
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on entities.source
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on entities.external_identifier
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on knowledge.claim
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on knowledge.claim_evidence
for all
to authenticated
using (true)
with check (true);
