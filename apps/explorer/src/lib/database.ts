import {
  DATABASE_POOL_SIZE,
  DATABASE_SSL_CA,
  DATABASE_STATEMENT_TIMEOUT_MS,
  DATABASE_URL,
  LOCAL_DATABASE_URL,
} from "astro:env/server";
import { Pool, type QueryResultRow } from "pg";
import { resolveDatabaseConfig } from "./database-config";

function loadDatabaseConfig() {
  return resolveDatabaseConfig({
    nodeEnv: process.env.NODE_ENV,
    databaseUrl: DATABASE_URL,
    localDatabaseUrl: LOCAL_DATABASE_URL,
    databaseSslCa: DATABASE_SSL_CA,
    databasePoolSize: DATABASE_POOL_SIZE,
    databaseStatementTimeoutMs: DATABASE_STATEMENT_TIMEOUT_MS,
  });
}

declare global {
  // Retain one development pool across Astro hot-module reloads.
  // eslint-disable-next-line no-var
  var __mosaExplorerPool: Pool | undefined;
}

function createPool(): Pool {
  const config = loadDatabaseConfig();

  return new Pool({
    connectionString: config.connectionString,
    application_name: "mosa-explorer",
    max: config.poolSize,
    idleTimeoutMillis: 10_000,
    connectionTimeoutMillis: 3_000,
    allowExitOnIdle: true,
    ssl: config.ssl,
    options: `-c default_transaction_read_only=on -c statement_timeout=${config.statementTimeoutMs} -c lock_timeout=1000`,
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
