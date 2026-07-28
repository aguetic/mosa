-- Privilege role for the MoSA explorer runtime. Login roles for each environment
-- (explorer_runtime_staging / explorer_runtime_production) are provisioned outside
-- version-controlled migrations and granted membership in this role.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'explorer_reader') then
    create role explorer_reader nologin;
  end if;
end
$$;

-- Allow privileged administrators (and pgTAP) to assume the role for verification.
grant explorer_reader to postgres;

grant usage on schema entities, knowledge, provenance, restitution to explorer_reader;
grant usage on schema extensions to explorer_reader;

grant select on
  entities.entity,
  entities.item,
  entities.agent,
  entities.place,
  entities.source,
  entities.external_identifier,
  entities.entity_display,
  knowledge.claim,
  knowledge.claim_evidence,
  knowledge.claim_details,
  knowledge.claim_evidence_details,
  provenance.event,
  restitution.case_record,
  restitution.case_item,
  restitution.case_party,
  restitution.case_action,
  restitution.action_party,
  restitution.case_document,
  restitution.action_document
to explorer_reader;

grant execute on function entities.search_normalise(text) to explorer_reader;
grant execute on function entities.entity_display_label(uuid) to explorer_reader;

alter default privileges for role postgres in schema entities
  grant select on tables to explorer_reader;
alter default privileges for role postgres in schema knowledge
  grant select on tables to explorer_reader;
alter default privileges for role postgres in schema provenance
  grant select on tables to explorer_reader;
alter default privileges for role postgres in schema restitution
  grant select on tables to explorer_reader;
