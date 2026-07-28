# Current deployment-relevant setup

This note is superseded by:

- [deployment.md](./deployment.md) — secrets, Supabase/Coolify provisioning, initial deploy
- [operations.md](./operations.md) — routine deploy, rollback, rotation, outage checks

The explorer runs as Astro SSR (`@astrojs/node` standalone) from a root multi-stage `Dockerfile`, talks to managed Supabase PostgreSQL over verified TLS with a read-only runtime login, and exposes token-gated `/livez` and `/readyz` for Coolify health checks.
