const DEFAULT_LOCAL_DATABASE_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres";
const LOOPBACK_HOSTS = new Set(["127.0.0.1", "localhost", "[::1]", "::1"]);
const DEFAULT_POOL_SIZE = 5;
const DEFAULT_STATEMENT_TIMEOUT_MS = 5_000;

export type DatabaseConfigInput = {
  nodeEnv?: string | undefined;
  databaseUrl?: string | undefined;
  /** @deprecated Prefer DATABASE_URL. Kept as a local-development alias. */
  localDatabaseUrl?: string | undefined;
  databaseSslCa?: string | undefined;
  databasePoolSize?: string | undefined;
  databaseStatementTimeoutMs?: string | undefined;
};

export type DatabaseSslConfig =
  | false
  | {
      rejectUnauthorized: true;
      ca: string;
    };

export type DatabaseConfig = {
  connectionString: string;
  ssl: DatabaseSslConfig;
  poolSize: number;
  statementTimeoutMs: number;
  isProduction: boolean;
};

function parsePositiveInteger(raw: string | undefined, fallback: number, label: string): number {
  if (raw === undefined || raw.trim() === "") {
    return fallback;
  }

  const value = Number(raw);
  if (!Number.isInteger(value) || value <= 0) {
    throw new Error(`${label} must be a positive integer.`);
  }

  return value;
}

function assertPostgresProtocol(connectionString: string, sourceLabel: string): URL {
  let url: URL;
  try {
    url = new URL(connectionString);
  } catch {
    throw new Error(`${sourceLabel} must be a valid URL.`);
  }

  if (url.protocol !== "postgres:" && url.protocol !== "postgresql:") {
    throw new Error(`${sourceLabel} must use the PostgreSQL protocol.`);
  }

  return url;
}

export function resolveDatabaseConfig(input: DatabaseConfigInput = {}): DatabaseConfig {
  const isProduction = input.nodeEnv === "production";
  const poolSize = parsePositiveInteger(
    input.databasePoolSize,
    DEFAULT_POOL_SIZE,
    "DATABASE_POOL_SIZE",
  );
  const statementTimeoutMs = parsePositiveInteger(
    input.databaseStatementTimeoutMs,
    DEFAULT_STATEMENT_TIMEOUT_MS,
    "DATABASE_STATEMENT_TIMEOUT_MS",
  );

  let connectionString: string;
  let sourceLabel: string;

  if (isProduction) {
    if (!input.databaseUrl) {
      throw new Error("DATABASE_URL is required in production.");
    }
    connectionString = input.databaseUrl;
    sourceLabel = "DATABASE_URL";
  } else if (input.databaseUrl) {
    connectionString = input.databaseUrl;
    sourceLabel = "DATABASE_URL";
  } else if (input.localDatabaseUrl) {
    connectionString = input.localDatabaseUrl;
    sourceLabel = "LOCAL_DATABASE_URL";
  } else {
    connectionString = DEFAULT_LOCAL_DATABASE_URL;
    sourceLabel = "default local database URL";
  }

  const url = assertPostgresProtocol(connectionString, sourceLabel);

  if (!isProduction && !LOOPBACK_HOSTS.has(url.hostname.toLowerCase())) {
    throw new Error(
      "The MoSA explorer only connects to a loopback PostgreSQL host outside production.",
    );
  }

  if (isProduction) {
    const ca = input.databaseSslCa?.trim();
    if (!ca) {
      throw new Error("DATABASE_SSL_CA is required in production.");
    }

    return {
      connectionString,
      ssl: {
        rejectUnauthorized: true,
        ca,
      },
      poolSize,
      statementTimeoutMs,
      isProduction,
    };
  }

  return {
    connectionString,
    ssl: false,
    poolSize,
    statementTimeoutMs,
    isProduction,
  };
}
