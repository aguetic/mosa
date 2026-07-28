-- Grants alone do not satisfy RLS. Policies only targeted `authenticated`, so
-- explorer_reader (and environment logins that inherit it) could SELECT but
-- always saw zero rows. Add read policies for the explorer privilege role.

create policy "explorer_reader select"
on entities.entity
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on entities.item
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on entities.agent
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on entities.place
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on entities.source
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on entities.external_identifier
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on knowledge.claim
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on knowledge.claim_evidence
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on provenance.event
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.case_record
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.case_item
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.case_party
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.case_action
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.action_party
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.case_document
for select
to explorer_reader
using (true);

create policy "explorer_reader select"
on restitution.action_document
for select
to explorer_reader
using (true);
