# MoSA Database

Local Supabase development environment for the MoSA entities, claims and evidence database.

## Requirements

- [mise](https://mise.jdx.dev/)
- Node.js 24, provisioned by mise
- pnpm 11, provisioned by mise
- Docker or another Docker-compatible container runtime
- Git

## Set up

```sh
mise install
mise x -- pnpm install --frozen-lockfile
mise x -- pnpm run db:start
mise x -- pnpm run db:reset
mise x -- pnpm run db:fixtures
```

`db:reset` applies migrations without loading `seed.sql`. `db:fixtures` then loads the Phase 1 competency cases used by local exploration and database tests.

Local Supabase Studio: http://localhost:54323

View local service URLs and keys:

```sh
mise x -- pnpm exec supabase status
```

## Development

Create a migration:

```sh
mise x -- pnpm exec supabase migration new describe_the_change
```

Rebuild the local database and reload Phase 1 fixtures:

```sh
mise x -- pnpm run db:reset
mise x -- pnpm run db:fixtures
```

Run static checks (format, types, unit tests, build):

```sh
mise x -- pnpm run verify:static
```

Run the full verification packet, including database tests and generated-type checking:

```sh
mise x -- pnpm run verify
```

Regenerate TypeScript types from the local database:

```sh
mise x -- pnpm run db:types
```

Stop Supabase:

```sh
mise x -- pnpm exec supabase stop
```

## Development principles

- Database changes must be made through committed migrations.
- Real or sensitive project data should not be committed as seed data.
