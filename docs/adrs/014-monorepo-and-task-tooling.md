# 014: Keep MoSA applications and database tooling in one monorepo

## Status

Accepted.

## Context

The database repository already contains the Astro research explorer in a pnpm workspace. The public museum website will also use Astro. Public presentation and the underlying model are expected to evolve together.

## Decision

- Rename the project to `mosa` and add the public application at `apps/website`.
- Keep the research explorer at `apps/explorer` and database migrations at `supabase/migrations`.
- Use mise for pinned development tools and just for repository tasks. Keep app-local package scripts for Astro and pnpm for dependency/workspace management.
- Build and deploy the applications separately. Preserve the root explorer Dockerfile for compatibility; give the website its own Dockerfile with the repository root as build context.
- Start the public website as a static app with no database dependency. Introduce a publication-aware read interface before exposing collection data.
- Extract shared workspace packages only when a concrete shared interface is needed. Application internals are not shared packages.

## Consequences

A single change can include migrations, read interfaces and UI updates with common verification. A shared commit does not make deployments atomic; migrations must remain compatible with old and new application versions.

The local Supabase project ID changes the development container namespace. Existing local volumes are retained, not automatically migrated. The hosted project identity is unchanged.

The website may be developed, built and deployed without the database. Its initial deployment is manual, pending hosting configuration and the public launch decision. Separate repository access or independent teams may justify extraction later.
