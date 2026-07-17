# MoSA Database

Local Supabase development environment for the MoSA entities, claims and evidence database.

## Requirements

- Node.js 20+
- pnpm
- Docker or another Docker-compatible container runtime
- Git

## Set up

```sh
pnpm install
pnpm db:start
pnpm exec supabase db reset
```

Local Supabase Studio: http://localhost:54323

View local service URLs and keys:

```sh
pnpm exec supabase status
```

## Development

Create a migration:

```sh
pnpm exec supabase migration new describe_the_change
```

Rebuild the local database:

```sh
pnpm exec supabase db reset
```

Run database tests and linting:

```sh
pnpm test
```

Stop Supabase:

```sh
pnpm exec supabase stop
```

## Development principles

- Database changes must be made through committed migrations.
- Real or sensitive project data should not be committed as seed data.
