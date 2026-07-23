import { readFile } from "node:fs/promises";
import path from "node:path";
import { Client } from "pg";
import { getLocalDatabaseUrl } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");
const mamariFixturePath = path.join(projectRoot, "supabase", "fixtures", "phase-2-mamari.sql");
const tePapaFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-2-te-papa-moai-kavakava.sql",
);

async function loadFixtureSql(fixturePath: string, label: string): Promise<void> {
  const [databaseUrl, fixtureSql] = await Promise.all([
    getLocalDatabaseUrl(projectRoot),
    readFile(fixturePath, "utf8"),
  ]);

  const client = new Client({
    application_name: "mosa-phase-2-fixture-loader",
    connectionString: databaseUrl,
  });

  await client.connect();

  try {
    await client.query(fixtureSql);
  } finally {
    await client.end();
  }

  process.stdout.write(`Loaded ${label} into the local database.\n`);
}

export async function loadPhase2Mamari(): Promise<void> {
  await loadFixtureSql(mamariFixturePath, "Phase 2 Mamari fixture");
}

export async function loadPhase2TePapaMoaiKavakava(): Promise<void> {
  await loadFixtureSql(tePapaFixturePath, "Phase 2 Te Papa moai kavakava fixture");
}

/** Loads the Mamari Phase 2 fixture. Prefer the named loaders when adding cases. */
export async function loadPhase2Fixtures(): Promise<void> {
  await loadPhase2Mamari();
}

async function main(): Promise<void> {
  try {
    await loadPhase2Mamari();
    await loadPhase2TePapaMoaiKavakava();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  void main();
}
