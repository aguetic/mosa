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
const hoaHakananaiaFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-2-hoa-hakananai-a.sql",
);
const hoaHakananaiaCommunityFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-2-hoa-hakananai-a-community.sql",
);
const hoaHakananaiaProductionFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-2-hoa-hakananai-a-production.sql",
);
const laSerenaMoaiFixturePath = path.join(
  projectRoot,
  "supabase",
  "fixtures",
  "phase-2-la-serena-moai.sql",
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

export async function loadPhase2HoaHakananaia(): Promise<void> {
  await loadFixtureSql(hoaHakananaiaFixturePath, "Phase 2 Hoa Hakananaiʻa fixture");
}

export async function loadPhase2HoaHakananaiaCommunity(): Promise<void> {
  await loadFixtureSql(
    hoaHakananaiaCommunityFixturePath,
    "Phase 2 Hoa Hakananaiʻa direct Rapa Nui evidence fixture",
  );
}

export async function loadPhase2HoaHakananaiaProduction(): Promise<void> {
  await loadFixtureSql(
    hoaHakananaiaProductionFixturePath,
    "Phase 2 Hoa Hakananaiʻa production and current-location fixture",
  );
}

export async function loadPhase2LaSerenaMoai(): Promise<void> {
  await loadFixtureSql(laSerenaMoaiFixturePath, "Phase 2 La Serena moai fixture");
}

/** Loads all Phase 2 competency fixtures. Prefer named loaders when adding a single case. */
export async function loadPhase2Fixtures(): Promise<void> {
  await loadPhase2Mamari();
  await loadPhase2TePapaMoaiKavakava();
  await loadPhase2HoaHakananaia();
  await loadPhase2HoaHakananaiaCommunity();
  await loadPhase2HoaHakananaiaProduction();
  await loadPhase2LaSerenaMoai();
}

async function main(): Promise<void> {
  try {
    await loadPhase2Fixtures();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  void main();
}
