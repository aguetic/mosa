begin;

create schema if not exists presentation;

create table presentation.foregrounded_claim (
    claim_id uuid primary key
        references knowledge.claim(id)
        on delete cascade
);

comment on schema presentation is
    'Explicit MoSA editorial selections used by default public-facing projections.';
comment on table presentation.foregrounded_claim is
    'Claims selected by MoSA for foregrounding in its default presentation. Selection is editorial salience, not epistemic or ontological priority.';

-- The selection row survives withdrawal or supersession so the editorial choice
-- remains reversible. Public-facing queries use this active-only projection.
create view presentation.foregrounded_claim_details
with (security_invoker = true)
as
select details.*
from presentation.foregrounded_claim as foregrounded
join knowledge.claim_details as details
    on details.claim_id = foregrounded.claim_id
where details.status = 'active';

comment on view presentation.foregrounded_claim_details is
    'One row per active foregrounded claim with attribution and display labels. Evidence remains available through knowledge.claim_evidence_details.';

revoke all on schema presentation from anon;
grant usage on schema presentation to authenticated, service_role, explorer_reader;

grant select, insert, update, delete
on presentation.foregrounded_claim
to authenticated, service_role;

grant select
on presentation.foregrounded_claim, presentation.foregrounded_claim_details
to explorer_reader;

grant select
on presentation.foregrounded_claim_details
to authenticated, service_role;

alter default privileges for role postgres
in schema presentation
grant select, insert, update, delete
on tables to authenticated, service_role;

alter default privileges for role postgres
in schema presentation
grant select on tables to explorer_reader;

alter table presentation.foregrounded_claim enable row level security;

create policy "authenticated project access"
on presentation.foregrounded_claim
for all
to authenticated
using (true)
with check (true);

create policy "explorer_reader select"
on presentation.foregrounded_claim
for select
to explorer_reader
using (true);

commit;
