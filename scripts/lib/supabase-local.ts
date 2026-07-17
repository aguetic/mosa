import { runCommand } from "./run-command";

const DATABASE_URL_ENV_KEYS = [
  "LOCAL_DATABASE_URL",
  "SUPABASE_DB_URL",
] as const;

function parseEnvironmentOutput(output: string): Map<string, string> {
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

export function getSupabaseExecutable(): string {
  if (process.env.SUPABASE_BIN) {
    return process.env.SUPABASE_BIN;
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
    getSupabaseExecutable(),
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
      "The local Supabase stack did not return DB_URL. Run `pnpm run db:start` first or set LOCAL_DATABASE_URL.",
    );
  }

  return databaseUrl;
}
