# MoSA bootstrap packets

Hand-translated object dossiers for the transactional importer (ADR 012).
These are the production-oriented packets derived from fixture *facts*, not
fixture SQL. Fixtures remain local test data.

## Dataset

| Field | Value |
| --- | --- |
| `dataset.key` | `mosa-bootstrap` |
| `dataset.version` | `2026-07-28` |
| Import order | See `manifest.json` |

Shared local keys (for example `agent:british-museum`) must stay identical
across packets so bindings reuse entities on later imports.

## Mapping

| Packet | Object key | External ID | Fixture sources |
| --- | --- | --- | --- |
| [`hoa-hakananai-a.packet.json`](hoa-hakananai-a.packet.json) | `item:hoa-hakananai-a` | `british-museum` / `Oc1869,1005.1`; `british-museum-aoa` / `1869,10-5.1` | `phase-1-cases.sql`, `phase-2-hoa-hakananai-a-production.sql` |
| [`kunstkamera-736-205.packet.json`](kunstkamera-736-205.packet.json) | `item:kunstkamera-736-205` | `kunstkamera` / `МАЭ № 736-205` | `phase-1-cases.sql` |
| [`te-papa-moai-kavakava.packet.json`](te-papa-moai-kavakava.packet.json) | `item:te-papa-moai-kavakava` | `te-papa-inventory` / `OL000342` | `phase-2-te-papa-moai-kavakava.sql` |
| [`mamari.packet.json`](mamari.packet.json) | `item:mamari` | `sscc-catalogue` / `P 003` | `phase-2-mamari.sql` |
| [`benin-ama.packet.json`](benin-ama.packet.json) | `item:benin-ama` | `british-museum` / `Af1898,0115.30` | `phase-2-benin-ama.sql` |

The committed schema example under `schemas/examples/hoa-hakananai-a.packet.json`
uses dataset key `mosa-bootstrap-example` and is for documentation only. Prefer
the bootstrap Hoa packet above for real imports.

## Commands

```bash
# Validate every bootstrap packet
just db-import-bootstrap-check

# Dry-run against the local stack (default)
just db-import-bootstrap

# Dry-run / apply against the linked remote project
# (same secrets pattern as `supabase db push`)
export SUPABASE_DB_PASSWORD='…'   # database password for the linked project
just db-import-bootstrap --linked
just db-import-bootstrap --linked --apply
just db-import-bootstrap --linked --apply   # expect no-op

# Or pass an explicit URL (escape hatch)
just db-import-bootstrap --database-url "$DATABASE_URL" --apply
```

`--linked` and `--database-url` are mutually exclusive. Default (neither flag)
is the local Supabase stack, so you cannot accidentally write to production.
Use a write-capable database role (the project database password), not the
read-only explorer runtime login.

Do not load `supabase/fixtures/*.sql` into staging or production.

## Deferred (not in these packets)

### Blocked until an absolute http(s) source exists

| Case | Fixture | Why deferred |
| --- | --- | --- |
| MPE 32571 (Partoriente) | `phase-1-cases.sql` | Evidence only on `docs/source-material/...` and a local photograph |
| Lost Gods curved moai | `phase-1-cases.sql` | Audiovisual source is a bare title, not a URL |
| Unidentified cranial remains | `phase-1-cases.sql` | Evidence only on `docs/source-material/Cráneo humano` |
| La Serena moai | `phase-2-la-serena-moai.sql` | Research note path only |

### Allowlisted facts intentionally omitted or later work

| Topic | Notes |
| --- | --- |
| Kunstkamera item `has_name` | Fixture has none; do not invent |
| Alternate Hoa name “Moai Hoa Haka Nanaia” | Evidenced only by deferred research note |
| Mamari `held_by` / `located_at` / `made_at` / `found_at` | Not present as summary claims in the fixture |
| Benin `located_at` | Not present as a current-state place claim in the fixture |

### Out of v1 importer scope (fixture has them; packets do not)

- `classified_as`, `made_of`, `described_as`, `made_during`
- `published_by`, `authored_by`, `depicts`
- `possibly_same_as`, `physical_remains_of`
- All provenance event graphs
- All restitution case records
- Non-URL research notes and bare-file photographs
