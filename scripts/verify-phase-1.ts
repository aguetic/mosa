import path from "node:path";
import { loadPhase1Fixtures } from "./load-phase-1-fixtures";
import { runCommand } from "./lib/run-command";
import { getSupabaseExecutable } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");
const supabase = getSupabaseExecutable();

async function verifyPhase1(): Promise<void> {
  await runCommand(supabase, ["start"], { cwd: projectRoot });
  await runCommand(
    supabase,
    ["db", "reset", "--local", "--no-seed"],
    { cwd: projectRoot },
  );

  await loadPhase1Fixtures();

  await runCommand(
    supabase,
    ["db", "lint", "--local", "--level", "error"],
    { cwd: projectRoot },
  );
  await runCommand(
    supabase,
    [
      "test",
      "db",
      "supabase/tests/database/phase-1-cases.test.sql",
      "--local",
    ],
    { cwd: projectRoot },
  );
}

async function main(): Promise<void> {
  try {
    await verifyPhase1();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

void main();
