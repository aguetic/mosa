begin;

create schema if not exists restitution;

create table restitution.case_record (
    id uuid primary key default gen_random_uuid(),
    reference text not null unique
        check (length(btrim(reference)) > 0),
    title text not null
        check (length(btrim(title)) > 0),
    status text not null
        check (status in ('open', 'closed')),
    opened_start date,
    opened_end date,
    opened_precision text,
    closed_start date,
    closed_end date,
    closed_precision text,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    updated_at timestamptz not null default now(),
    updated_by uuid references auth.users(id) on delete set null,
    constraint case_opened_date_shape
        check (
            (
                opened_start is null
                and opened_end is null
                and opened_precision is null
            )
            or (
                opened_start is not null
                and opened_end is not null
                and opened_start <= opened_end
                and opened_precision in ('day', 'month', 'year')
                and (
                    (
                        opened_precision = 'day'
                        and opened_start = opened_end
                    )
                    or (
                        opened_precision = 'month'
                        and extract(day from opened_start) = 1
                        and opened_end =
                            (opened_start + interval '1 month - 1 day')::date
                    )
                    or (
                        opened_precision = 'year'
                        and opened_start =
                            make_date(extract(year from opened_start)::integer, 1, 1)
                        and opened_end =
                            make_date(extract(year from opened_start)::integer, 12, 31)
                    )
                )
            )
        ),
    constraint case_closed_date_shape
        check (
            (
                closed_start is null
                and closed_end is null
                and closed_precision is null
            )
            or (
                closed_start is not null
                and closed_end is not null
                and closed_start <= closed_end
                and closed_precision in ('day', 'month', 'year')
                and (
                    (
                        closed_precision = 'day'
                        and closed_start = closed_end
                    )
                    or (
                        closed_precision = 'month'
                        and extract(day from closed_start) = 1
                        and closed_end =
                            (closed_start + interval '1 month - 1 day')::date
                    )
                    or (
                        closed_precision = 'year'
                        and closed_start =
                            make_date(extract(year from closed_start)::integer, 1, 1)
                        and closed_end =
                            make_date(extract(year from closed_start)::integer, 12, 31)
                    )
                )
            )
        ),
    constraint open_case_has_no_closed_date
        check (
            status <> 'open'
            or (
                closed_start is null
                and closed_end is null
                and closed_precision is null
            )
        ),
    constraint closed_case_has_closed_date
        check (
            status <> 'closed'
            or (
                closed_start is not null
                and closed_end is not null
                and closed_precision is not null
            )
        )
);

create table restitution.case_item (
    case_id uuid not null,
    item_id uuid not null,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    primary key (case_id, item_id),
    constraint case_item_case_record_fkey
        foreign key (case_id)
        references restitution.case_record(id)
        on delete cascade,
    constraint case_item_item_fkey
        foreign key (item_id)
        references entities.item(id)
        on delete restrict
);

create table restitution.case_party (
    id uuid primary key default gen_random_uuid(),
    case_id uuid not null,
    agent_id uuid not null,
    role text not null
        check (length(btrim(role)) > 0),
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    constraint case_party_case_record_fkey
        foreign key (case_id)
        references restitution.case_record(id)
        on delete cascade,
    constraint case_party_agent_fkey
        foreign key (agent_id)
        references entities.agent(id)
        on delete restrict,
    unique (case_id, agent_id, role)
);

create table restitution.case_action (
    id uuid primary key default gen_random_uuid(),
    case_id uuid not null,
    sequence_number integer not null
        check (sequence_number > 0),
    action_kind text not null
        check (
            action_kind in (
                'outreach',
                'request',
                'engagement',
                'recommendation',
                'decision',
                'handover'
            )
        ),
    description text not null
        check (length(btrim(description)) > 0),
    occurred_start date,
    occurred_end date,
    occurred_precision text,
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    updated_at timestamptz not null default now(),
    updated_by uuid references auth.users(id) on delete set null,
    constraint case_action_case_record_fkey
        foreign key (case_id)
        references restitution.case_record(id)
        on delete cascade,
    constraint case_action_date_shape
        check (
            (
                occurred_start is null
                and occurred_end is null
                and occurred_precision is null
            )
            or (
                occurred_start is not null
                and occurred_end is not null
                and occurred_start <= occurred_end
                and occurred_precision in ('day', 'month', 'year')
                and (
                    (
                        occurred_precision = 'day'
                        and occurred_start = occurred_end
                    )
                    or (
                        occurred_precision = 'month'
                        and extract(day from occurred_start) = 1
                        and occurred_end =
                            (occurred_start + interval '1 month - 1 day')::date
                    )
                    or (
                        occurred_precision = 'year'
                        and occurred_start =
                            make_date(extract(year from occurred_start)::integer, 1, 1)
                        and occurred_end =
                            make_date(extract(year from occurred_start)::integer, 12, 31)
                    )
                )
            )
        ),
    unique (id, case_id),
    unique (case_id, sequence_number)
);

create table restitution.action_party (
    id uuid primary key default gen_random_uuid(),
    action_id uuid not null,
    agent_id uuid not null,
    role text not null
        check (length(btrim(role)) > 0),
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    constraint action_party_case_action_fkey
        foreign key (action_id)
        references restitution.case_action(id)
        on delete cascade,
    constraint action_party_agent_fkey
        foreign key (agent_id)
        references entities.agent(id)
        on delete restrict,
    unique (action_id, agent_id, role)
);

create table restitution.case_document (
    id uuid primary key default gen_random_uuid(),
    case_id uuid not null,
    source_id uuid not null,
    document_role text not null
        check (length(btrim(document_role)) > 0),
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    constraint case_document_case_record_fkey
        foreign key (case_id)
        references restitution.case_record(id)
        on delete cascade,
    constraint case_document_source_fkey
        foreign key (source_id)
        references entities.source(id)
        on delete restrict,
    unique (id, case_id),
    unique (case_id, source_id, document_role)
);

create table restitution.action_document (
    id uuid primary key default gen_random_uuid(),
    action_id uuid not null,
    document_id uuid not null,
    case_id uuid not null,
    relationship text
        check (relationship is null or length(btrim(relationship)) > 0),
    created_at timestamptz not null default now(),
    created_by uuid references auth.users(id) on delete set null,
    constraint action_document_action_case_fkey
        foreign key (action_id, case_id)
        references restitution.case_action(id, case_id)
        on delete cascade,
    constraint action_document_document_case_fkey
        foreign key (document_id, case_id)
        references restitution.case_document(id, case_id)
        on delete cascade,
    unique (action_id, document_id)
);

create index case_item_item_idx
    on restitution.case_item (item_id);

create index case_party_case_idx
    on restitution.case_party (case_id);

create index case_party_agent_idx
    on restitution.case_party (agent_id);

create index case_action_case_idx
    on restitution.case_action (case_id);

create index case_action_date_idx
    on restitution.case_action (occurred_start, occurred_end);

create index action_party_action_idx
    on restitution.action_party (action_id);

create index action_party_agent_idx
    on restitution.action_party (agent_id);

create index case_document_case_idx
    on restitution.case_document (case_id);

create index case_document_source_idx
    on restitution.case_document (source_id);

create index action_document_action_idx
    on restitution.action_document (action_id);

create index action_document_document_idx
    on restitution.action_document (document_id);

create trigger set_restitution_case_updated_at
before update on restitution.case_record
for each row
execute function entities.set_updated_at();

create trigger set_restitution_action_updated_at
before update on restitution.case_action
for each row
execute function entities.set_updated_at();

comment on schema restitution is
    'Operational restitution case-management records associated with collection items.';
comment on table restitution.case_record is
    'A managed restitution, repatriation or return case. Status is operational and does not judge the merits of the case.';
comment on table restitution.case_item is
    'Associates a case with an item without implying ownership, entitlement or an expected outcome.';
comment on table restitution.case_party is
    'Operational party roles within a restitution case.';
comment on table restitution.case_action is
    'Administrative actions in a restitution case. Actions are direct case-management records, not knowledge claims.';
comment on table restitution.action_party is
    'Agent participation in one restitution action.';
comment on table restitution.case_document is
    'Administrative documents associated with a restitution case. These links are not claim evidence.';
comment on table restitution.action_document is
    'Optional many-to-many links between case documents and actions. A document may remain case-level only.';

revoke all on schema restitution from anon;
grant usage on schema restitution to authenticated, service_role;

grant select, insert, update, delete
on all tables in schema restitution
to authenticated, service_role;

alter default privileges for role postgres
in schema restitution
grant select, insert, update, delete
on tables to authenticated, service_role;

alter table restitution.case_record enable row level security;
alter table restitution.case_item enable row level security;
alter table restitution.case_party enable row level security;
alter table restitution.case_action enable row level security;
alter table restitution.action_party enable row level security;
alter table restitution.case_document enable row level security;
alter table restitution.action_document enable row level security;

create policy "authenticated project access"
on restitution.case_record
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.case_item
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.case_party
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.case_action
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.action_party
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.case_document
for all
to authenticated
using (true)
with check (true);

create policy "authenticated project access"
on restitution.action_document
for all
to authenticated
using (true)
with check (true);

commit;
