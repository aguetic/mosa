import {
  DATABASE_POOL_SIZE,
  DATABASE_SSL_CA,
  DATABASE_STATEMENT_TIMEOUT_MS,
  DATABASE_URL,
  LOCAL_DATABASE_URL,
} from "astro:env/server";
import { Pool, type QueryResultRow } from "pg";
import { resolveDatabaseConfig } from "./database-config";

const SHUTDOWN_GRACE_MS = 10_000;

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
  // eslint-disable-next-line no-var
  var __mosaExplorerShuttingDown: boolean | undefined;
  // eslint-disable-next-line no-var
  var __mosaExplorerShutdownRegistered: boolean | undefined;
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

export function isShuttingDown(): boolean {
  return globalThis.__mosaExplorerShuttingDown === true;
}

export async function closePool(): Promise<void> {
  const pool = globalThis.__mosaExplorerPool;
  if (!pool) {
    return;
  }

  globalThis.__mosaExplorerPool = undefined;
  await pool.end();
}

async function shutdown(): Promise<void> {
  if (globalThis.__mosaExplorerShuttingDown) {
    return;
  }

  globalThis.__mosaExplorerShuttingDown = true;

  const forceExit = setTimeout(() => {
    process.exit(1);
  }, SHUTDOWN_GRACE_MS);
  forceExit.unref();

  try {
    await closePool();
    process.exit(0);
  } catch {
    process.exit(1);
  }
}

export function registerGracefulShutdown(): void {
  if (globalThis.__mosaExplorerShutdownRegistered) {
    return;
  }

  globalThis.__mosaExplorerShutdownRegistered = true;

  process.once("SIGTERM", () => {
    void shutdown();
  });
  process.once("SIGINT", () => {
    void shutdown();
  });
}

registerGracefulShutdown();

export async function query<Row extends QueryResultRow>(
  text: string,
  values: readonly unknown[] = [],
): Promise<Row[]> {
  if (isShuttingDown()) {
    throw new Error("Database pool is shutting down.");
  }

  const result = await getPool().query<Row>(text, [...values]);
  return result.rows;
}
