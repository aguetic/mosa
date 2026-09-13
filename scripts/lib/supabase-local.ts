import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { runCommand } from "./run-command";

const DATABASE_URL_ENV_KEYS = ["LOCAL_DATABASE_URL", "SUPABASE_DB_URL"] as const;

export function injectPasswordIntoDatabaseUrl(databaseUrl: string, password: string): string {
  let parsed: URL;
  try {
    parsed = new URL(databaseUrl);
  } catch {
    throw new Error(`Invalid database URL from the linked project: ${databaseUrl}`);
  }

  parsed.password = password;
  return parsed.toString();
}

export function buildDirectDatabaseUrl(projectRef: string, password: string): string {
  const ref = projectRef.trim();
  if (!ref) {
    throw new Error("Linked project ref is empty. Re-run `supabase link --project-ref <ref>`.");
  }

  const url = new URL(`postgresql://postgres@db.${ref}.supabase.co:5432/postgres`);
  url.password = password;
  return url.toString();
}

export function parseEnvironmentOutput(output: string): Map<string, string> {
  const values = new Map<string, string>();

  for (const rawLine of output.split(/\r?\n/u)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");
    if (separatorIndex <= 0) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    let value = line.slice(separatorIndex + 1).trim();

    if (
      value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'")))
    ) {
      value = value.slice(1, -1);
    }

    values.set(key, value);
  }

  return values;
}

export function getSupabaseExecutable(projectRoot = process.cwd()): string {
  if (process.env.SUPABASE_BIN) {
    return process.env.SUPABASE_BIN;
  }

  const localBinary = path.join(
    projectRoot,
    "node_modules",
    ".bin",
    process.platform === "win32" ? "supabase.cmd" : "supabase",
  );
  if (existsSync(localBinary)) {
    return localBinary;
  }

  return process.platform === "win32" ? "supabase.cmd" : "supabase";
}

export async function getLocalDatabaseUrl(projectRoot: string): Promise<string> {
  for (const key of DATABASE_URL_ENV_KEYS) {
    const value = process.env[key];
    if (value) {
      return value;
    }
  }

  const output = await runCommand(
    getSupabaseExecutable(projectRoot),
    ["status", "--output", "env"],
    {
      cwd: projectRoot,
      captureOutput: true,
    },
  );

  const values = parseEnvironmentOutput(output);
  const databaseUrl = values.get("DB_URL");

  if (!databaseUrl) {
    throw new Error(
      "The local Supabase stack did not return DB_URL. Run `just db-start` first or set LOCAL_DATABASE_URL.",
    );
  }

  return databaseUrl;
}

/**
 * Build a write URL for the project linked by `supabase link`.
 *
 * Idiomatic Supabase CLI auth: project ref from link metadata, password from
 * SUPABASE_DB_PASSWORD (same secret used for `supabase db push` in CI).
 * Prefer the linked pooler URL when present; otherwise fall back to the
 * direct db.<ref>.supabase.co host.
 */
export async function getLinkedDatabaseUrl(projectRoot: string): Promise<string> {
  const password = process.env.SUPABASE_DB_PASSWORD;
  if (!password) {
    throw new Error(
      "SUPABASE_DB_PASSWORD is required for --linked. Export the database password for the linked project (same value used with `supabase db push`).",
    );
  }

  const tempDir = path.join(projectRoot, "supabase", ".temp");
  const poolerUrlPath = path.join(tempDir, "pooler-url");
  const projectRefPath = path.join(tempDir, "project-ref");

  if (existsSync(poolerUrlPath)) {
    const poolerUrl = (await readFile(poolerUrlPath, "utf8")).trim();
    if (poolerUrl) {
      return injectPasswordIntoDatabaseUrl(poolerUrl, password);
    }
  }

  if (existsSync(projectRefPath)) {
    const projectRef = (await readFile(projectRefPath, "utf8")).trim();
    if (projectRef) {
      return buildDirectDatabaseUrl(projectRef, password);
    }
  }

  throw new Error(
    "No linked Supabase project found under supabase/.temp. Run `just supabase link --project-ref <ref>` first.",
  );
}

export interface ResolveImportDatabaseUrlOptions {
  databaseUrl?: string;
  linked?: boolean;
}

export async function resolveImportDatabaseUrl(
  projectRoot: string,
  options: ResolveImportDatabaseUrlOptions,
): Promise<string> {
  if (options.databaseUrl && options.linked) {
    throw new Error("--database-url and --linked are mutually exclusive.");
  }

  if (options.databaseUrl) {
    return options.databaseUrl;
  }

  if (options.linked) {
    return getLinkedDatabaseUrl(projectRoot);
  }

  return getLocalDatabaseUrl(projectRoot);
}
