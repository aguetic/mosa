# MoSA Phase 1 explorer

A local, read-only Astro interface for visually inspecting the synthetic Phase 1 database fixtures while the model is being developed.

It is intentionally not an authoring interface. It does not provide authentication, entity creation, claim creation, evidence entry, editing, deletion, import, provenance, restitution, publication, or workflow controls.

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

- `/` searches entities by working label or external identifier.
- `/entities/:id` shows subtype data, identifiers, outgoing claims, incoming claims, and evidence summaries.
- `/claims/:id` shows one claim and all attached evidence.
