import { LOCAL_DATABASE_URL } from "astro:env/server";
import { Pool, type QueryResultRow } from "pg";

const DEFAULT_LOCAL_DATABASE_URL =
  "postgresql://postgres:postgres@127.0.0.1:54322/postgres";
const LOOPBACK_HOSTS = new Set(["127.0.0.1", "localhost", "[::1]", "::1"]);

function resolveConnectionString(): string {
  const connectionString = LOCAL_DATABASE_URL ?? DEFAULT_LOCAL_DATABASE_URL;
  const url = new URL(connectionString);

  if (url.protocol !== "postgres:" && url.protocol !== "postgresql:") {
    throw new Error("LOCAL_DATABASE_URL must use the PostgreSQL protocol.");
  }

  if (!LOOPBACK_HOSTS.has(url.hostname.toLowerCase())) {
    throw new Error(
      "The Phase 1 explorer only connects to a loopback PostgreSQL host.",
    );
  }

  return connectionString;
}

declare global {
  // Retain one development pool across Astro hot-module reloads.
  // eslint-disable-next-line no-var
  var __mosaExplorerPool: Pool | undefined;
}

function createPool(): Pool {
  return new Pool({
    connectionString: resolveConnectionString(),
    application_name: "mosa-phase-1-explorer",
    max: 4,
    idleTimeoutMillis: 10_000,
    connectionTimeoutMillis: 3_000,
    allowExitOnIdle: true,
    ssl: false,
    options:
      "-c default_transaction_read_only=on -c statement_timeout=5000 -c lock_timeout=1000",
  });
}

function getPool(): Pool {
  if (!globalThis.__mosaExplorerPool) {
    globalThis.__mosaExplorerPool = createPool();
  }

  return globalThis.__mosaExplorerPool;
}

export async function query<Row extends QueryResultRow>(
  text: string,
  values: readonly unknown[] = [],
): Promise<Row[]> {
  const result = await getPool().query<Row>(text, [...values]);
  return result.rows;
}
