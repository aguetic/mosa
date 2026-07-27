import { readFile } from "node:fs/promises";
import path from "node:path";
import { Client } from "pg";
import { getLocalDatabaseUrl } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");
const aberdeenFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-3-aberdeen-head.sql",
);
const hoaFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-3-hoa-hakananai-a.sql",
);

async function loadFixtureSql(fixturePath: string, label: string): Promise<void> {
  const [databaseUrl, fixtureSql] = await Promise.all([
    getLocalDatabaseUrl(projectRoot),
    readFile(fixturePath, "utf8"),
  ]);

  const client = new Client({
    application_name: "mosa-phase-3-fixture-loader",
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

export async function loadPhase3AberdeenHead(): Promise<void> {
  await loadFixtureSql(aberdeenFixturePath, "Phase 3 Aberdeen Head restitution fixture");
}

export async function loadPhase3HoaHakananaia(): Promise<void> {
  await loadFixtureSql(hoaFixturePath, "Phase 3 Hoa Hakananaiʻa restitution fixture");
}

export async function loadPhase3Fixtures(): Promise<void> {
  await loadPhase3AberdeenHead();
  await loadPhase3HoaHakananaia();
}

async function main(): Promise<void> {
  try {
    await loadPhase3Fixtures();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  void main();
}
