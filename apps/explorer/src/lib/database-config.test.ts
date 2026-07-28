import { describe, expect, it } from "vitest";
import { resolveDatabaseConfig } from "./database-config";

describe("resolveDatabaseConfig", () => {
  it("fails in production when DATABASE_URL is missing", () => {
    expect(() => resolveDatabaseConfig({ nodeEnv: "production" })).toThrow(
      "DATABASE_URL is required in production.",
    );
  });

  it("uses the local loopback default in development", () => {
    const config = resolveDatabaseConfig({ nodeEnv: "development" });

    expect(config.isProduction).toBe(false);
    expect(config.connectionString).toBe("postgresql://postgres:postgres@127.0.0.1:54322/postgres");
    expect(config.ssl).toBe(false);
    expect(config.poolSize).toBe(5);
    expect(config.statementTimeoutMs).toBe(5_000);
  });

  it("enables certificate verification in production", () => {
    const ca = "-----BEGIN CERTIFICATE-----\nTEST\n-----END CERTIFICATE-----";
    const config = resolveDatabaseConfig({
      nodeEnv: "production",
      databaseUrl: "postgresql://explorer:secret@db.example.com:5432/postgres",
      databaseSslCa: ca,
    });

    expect(config.isProduction).toBe(true);
    expect(config.ssl).toEqual({
      rejectUnauthorized: true,
      ca,
    });
  });

  it("rejects invalid pool and timeout settings", () => {
    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "development",
        databasePoolSize: "0",
      }),
    ).toThrow("DATABASE_POOL_SIZE must be a positive integer.");

    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "development",
        databaseStatementTimeoutMs: "-1",
      }),
    ).toThrow("DATABASE_STATEMENT_TIMEOUT_MS must be a positive integer.");

    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "development",
        databasePoolSize: "abc",
      }),
    ).toThrow("DATABASE_POOL_SIZE must be a positive integer.");
  });

  it("accepts LOCAL_DATABASE_URL as a deprecated development alias", () => {
    const config = resolveDatabaseConfig({
      nodeEnv: "development",
      localDatabaseUrl: "postgresql://postgres:postgres@127.0.0.1:54322/postgres",
    });

    expect(config.connectionString).toBe("postgresql://postgres:postgres@127.0.0.1:54322/postgres");
  });

  it("prefers DATABASE_URL over LOCAL_DATABASE_URL", () => {
    const config = resolveDatabaseConfig({
      nodeEnv: "development",
      databaseUrl: "postgresql://postgres:postgres@127.0.0.1:54322/other",
      localDatabaseUrl: "postgresql://postgres:postgres@127.0.0.1:54322/postgres",
    });

    expect(config.connectionString).toBe("postgresql://postgres:postgres@127.0.0.1:54322/other");
  });

  it("never falls back to the local default or LOCAL_DATABASE_URL in production", () => {
    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "production",
        localDatabaseUrl: "postgresql://postgres:postgres@127.0.0.1:54322/postgres",
        databaseSslCa: "ca",
      }),
    ).toThrow("DATABASE_URL is required in production.");

    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "production",
        databaseSslCa: "ca",
      }),
    ).toThrow("DATABASE_URL is required in production.");
  });

  it("requires DATABASE_SSL_CA in production", () => {
    expect(() =>
      resolveDatabaseConfig({
        nodeEnv: "production",
        databaseUrl: "postgresql://explorer:secret@db.example.com:5432/postgres",
      }),
    ).toThrow("DATABASE_SSL_CA is required in production.");
  });
});
