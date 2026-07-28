# Deployment

Secret-free checklist for deploying the MoSA explorer with Coolify and managed Supabase.

Do not put passwords, tokens, certificates, or live connection strings in this repository.

## Required GitHub secrets (`production` environment)

| Secret | Purpose |
|--------|---------|
| `SUPABASE_ACCESS_TOKEN` | Supabase CLI authentication for `db push` |
| `SUPABASE_PROJECT_ID` | Production project ref |
| `SUPABASE_DB_PASSWORD` | Database password for migration apply |
| `COOLIFY_DEPLOY_WEBHOOK` | Triggers a Coolify deploy for the app |
| `COOLIFY_API_TOKEN` | Reserved for Coolify API use if needed later |
| `PRODUCTION_URL` | Public URL used for post-deploy smoke tests |

## Required Coolify runtime secrets

| Variable | Notes |
|----------|-------|
| `DATABASE_URL` | Runtime login URL (literal if the password contains `$`) |
| `DATABASE_SSL_CA` | Supabase CA certificate (multiline) |
| `HEALTHCHECK_TOKEN` | Shared with Docker/`X-Health-Token` health checks |
| `NODE_ENV` | `production` |
| `DATABASE_POOL_SIZE` | Optional; default `5` |
| `DATABASE_STATEMENT_TIMEOUT_MS` | Optional; default `5000` |

`HOST` defaults to `0.0.0.0` and `PORT` to `4321` in the image.

## Explorer environment variables

| Variable | Required in production | Notes |
|----------|------------------------|-------|
| `DATABASE_URL` | yes | Prefer over deprecated `LOCAL_DATABASE_URL` |
| `DATABASE_SSL_CA` | yes | Verified TLS |
| `HEALTHCHECK_TOKEN` | yes | Authorizes `/livez` and `/readyz` |
| `DATABASE_POOL_SIZE` | no | Default `5` |
| `DATABASE_STATEMENT_TIMEOUT_MS` | no | Default `5000` |
| `LOCAL_DATABASE_URL` | no | Dev-only deprecated alias; ignored as production source |

Unauthorized health requests return `404` and do not query PostgreSQL. External uptime checks should hit a normal page (for example `/`), not `/readyz`.

## Managed Supabase provisioning checklist

1. Create one production project on PostgreSQL 17 in a region near the Coolify server.
2. Confirm required extensions match local development (including `unaccent` in `extensions`).
3. Apply migrations (`supabase db push` / CI deploy job). Do not load fixtures or `seed.sql`.
4. Create login `explorer_runtime_production` outside Git:
   - generated password
   - `grant explorer_reader to explorer_runtime_production`
   - `alter role ... set default_transaction_read_only = on`
   - short `statement_timeout` and a small connection limit
5. Build `DATABASE_URL` from that login.
6. Disable the Data API. Leave Auth, Storage, Realtime, and Functions unused.
7. Download the database CA certificate for `DATABASE_SSL_CA`.
8. From the Coolify host, test connectivity:
   - prefer the direct PostgreSQL endpoint if outbound IPv6 works
   - otherwise Supavisor **session** mode on port `5432` (not transaction mode)
9. Enable SSL enforcement after the verified-TLS test succeeds.
10. Restrict network access to the Coolify egress address where practical.
11. Confirm managed daily backups are active.

A staging project and PITR can wait until there is a demonstrated need.

## Coolify application checklist

1. Connect the private GitHub repository through the Coolify GitHub App.
2. Create a Dockerfile application:
   - branch `main`
   - build pack Dockerfile
   - base directory `/`
   - Dockerfile `/Dockerfile`
   - internal port `4321`
   - no host port mapping
   - no persistent volume
   - rolling updates enabled
   - default container naming
3. Configure the production domain and DNS.
4. Set the runtime-only secrets listed above (not build variables).
5. Point Coolify health checks at `/readyz` with header `X-Health-Token: <HEALTHCHECK_TOKEN>`.
6. **Disable auto-deploy on push** so migrations always run before the new container ships.
7. Perform the first deployment manually and verify it before relying on the GitHub deploy job.

## Initial deployment checklist

1. Apply all migrations to production and confirm with `supabase migration list`.
2. Verify `explorer_runtime_production` can `SELECT` expected objects and cannot write or run DDL.
3. Trigger the first Coolify deployment for the image built from this repository.
4. Confirm:
   - container health passes
   - TLS certificate is issued for the domain
   - authorized `/livez` and `/readyz` succeed
   - representative explorer pages render
   - no secrets appear in build or application logs
5. Point production DNS only after those checks pass.
6. Enable or rely on the GitHub Actions `deploy` job on `main` (CI must pass `static`, `database`, and `docker` first).
