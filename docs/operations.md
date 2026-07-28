# Operations

Short operational notes for the Coolify + managed Supabase explorer deployment. No live credentials belong in this file.

## Routine deployment

1. Merge to `main` only after CI passes (`static`, `database`, `docker`).
2. The `deploy` job:
   - applies pending Supabase migrations with `supabase db push`
   - triggers the Coolify deploy webhook
   - retries `PRODUCTION_URL` for a bounded period
3. Keep Coolify auto-deploy disabled so the app never ships before migrations.

Use expand/contract migrations so a successful migration remains compatible with both old and new containers during rolling updates.

## Application rollback

- Roll back the application by redeploying a previously successful Coolify deployment/version.
- Do not roll back schema with reverse migrations.
- If a release is bad only in the app layer, keep the newer compatible schema and ship an older image, or ship a forward fix.

## Forward-fixing failed database migrations

- Treat migrations as forward-only.
- If `db push` fails, fix forward with a new migration and re-run deploy.
- Do not hand-edit production schema outside the migration history.
- If a migration applied but the app deploy failed, either complete the app deploy for that commit or ship a follow-up commit that is schema-compatible.

## Database credential rotation

1. Create a new password for `explorer_runtime_production` in the Supabase SQL editor or dashboard (outside Git).
2. Update Coolify `DATABASE_URL` with the new password (literal value if it contains `$`).
3. Redeploy or restart the Coolify application so new connections use the rotated secret.
4. Confirm authorized `/readyz` and a normal page still succeed.
5. Never commit passwords, paste them into migrations, or leave them in shell history files that are shared.

## Backups and logs

- **Backups:** use Supabase managed daily backups for the production project. Restore through the Supabase dashboard/support flow when needed.
- **Application logs:** Coolify application logs for the explorer container.
- **Migration / deploy logs:** GitHub Actions `deploy` job for the `production` environment.
- **Database logs:** Supabase project logs.

## Basic outage checks

1. Is the Coolify application running and healthy?
2. Does `PRODUCTION_URL` respond?
3. Does authorized `/readyz` return `204`? (`X-Health-Token` header required; public callers should see `404`.)
4. Is the Supabase project up? Can you connect with verified TLS from the Coolify host?
5. Did the latest GitHub deploy job fail on migrations or on the smoke test?
6. Were Coolify runtime secrets recently changed (`DATABASE_URL`, `DATABASE_SSL_CA`, `HEALTHCHECK_TOKEN`)?
