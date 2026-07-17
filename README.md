# MoSA Database

Local Supabase development environment for the MoSA entities, claims and evidence database.

## Requirements

- Node.js 20+
- Docker or another Docker-compatible container runtime
- Git

## Set up

```sh
npm install
npx supabase start
npx supabase db reset
```

Local Supabase Studio: http://localhost:54323

View local service URLs and keys:

```sh
npx supabase status
```

## Database structure

The initial schema contains:

```
entities.entity
entities.item
entities.agent
entities.place
entities.source
entities.external_identifier
knowledge.claim
knowledge.claim_evidence
```

Migrations are stored in `supabase/migrations/`.

The local development fixture is stored in `supabase/seed.sql`.

## Development

Create a migration:

```sh
npx supabase migration new describe_the_change
```

Rebuild the local database:

```sh
npx supabase db reset
```

Run database tests and linting:

```sh
npx supabase test db
npx supabase db lint
```

Stop Supabase:

```sh
npx supabase stop
```

## Principles

- Database changes must be made through committed migrations.
- Institutional sources remain separate from the entities they describe.
- Descriptive statements are stored as attributed claims.
- A claim points either to another entity or to a structured literal value.
- Real or sensitive project data should not be committed as seed data.
