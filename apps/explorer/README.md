# MoSA research explorer

A local, read-only Astro interface for visually inspecting the synthetic Phase 1 and Phase 2 database fixtures while the model is being developed.

It is intentionally not an authoring interface. It does not provide authentication, entity creation, claim creation, evidence entry, editing, deletion, import, restitution, publication, or workflow controls. It can inspect Phase 2 provenance events but cannot create or edit them.

## Run locally

From the repository root:

```sh
pnpm run db:start
pnpm run db:fixtures
pnpm run explorer:dev
```

Open <http://localhost:4321>.

The app defaults to the standard local Supabase PostgreSQL URL. Override it by copying `.env.example` to `.env` and changing `LOCAL_DATABASE_URL`. The explorer rejects non-loopback database hosts and opens every connection with PostgreSQL's read-only transaction setting.

## Views

- `/` searches entities by derived display label, `has_name` values, external identifiers, or source references.
- `/entities/:id` shows subtype data, identifiers, outgoing claims, incoming claims, and evidence summaries.
- `/claims/:id` shows one claim and all attached evidence.
- `/events/:id` shows one provenance event and its attributed statements.
- Item pages show sourced provenance events ordered by reported date.
