import { readFile } from "node:fs/promises";
import path from "node:path";
import { Client } from "pg";
import { getLocalDatabaseUrl } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");
const fixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-1-cases.sql",
);

export async function loadPhase1Fixtures(): Promise<void> {
  const [databaseUrl, fixtureSql] = await Promise.all([
    getLocalDatabaseUrl(projectRoot),
    readFile(fixturePath, "utf8"),
  ]);

  const client = new Client({
    application_name: "mosa-phase-1-fixture-loader",
    connectionString: databaseUrl,
  });

  await client.connect();

  try {
    await client.query(fixtureSql);
  } finally {
    await client.end();
  }

  process.stdout.write("Loaded Phase 1 fixtures into the local database.\n");
}

async function main(): Promise<void> {
  try {
    await loadPhase1Fixtures();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  void main();
}
