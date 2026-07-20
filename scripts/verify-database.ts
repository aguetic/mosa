import path from "node:path";
import { runCommand } from "./lib/run-command";
import { getSupabaseExecutable } from "./lib/supabase-local";
import { loadPhase1Fixtures } from "./load-phase-1-fixtures";
import { loadPhase2Fixtures } from "./load-phase-2-fixtures";

const projectRoot = path.resolve(__dirname, "..");
const supabase = getSupabaseExecutable();

async function verifyDatabase(): Promise<void> {
  await runCommand(supabase, ["start"], { cwd: projectRoot });
  await runCommand(supabase, ["db", "reset", "--local", "--no-seed"], { cwd: projectRoot });

  await loadPhase1Fixtures();
  await loadPhase2Fixtures();

  await runCommand(supabase, ["db", "lint", "--local", "--level", "error"], { cwd: projectRoot });
  await runCommand(
    supabase,
    ["test", "db", "supabase/tests/database/phase-1-cases.test.sql", "--local"],
    { cwd: projectRoot },
  );
  await runCommand(
    supabase,
    ["test", "db", "supabase/tests/database/phase-2-mamari.test.sql", "--local"],
    { cwd: projectRoot },
  );
}

async function main(): Promise<void> {
  try {
    await verifyDatabase();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

void main();
