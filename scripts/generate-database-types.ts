import { randomBytes } from "node:crypto";
import { readFile, rename, unlink, writeFile } from "node:fs/promises";
import path from "node:path";
import { runCommand } from "./lib/run-command";
import { getSupabaseExecutable } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");
const outputPath = path.join(projectRoot, "src/lib/database.types.ts");

function normalizeGeneratedTypes(output: string): string {
  return output.endsWith("\n") ? output : `${output}\n`;
}

async function generateDatabaseTypes(): Promise<string> {
  const supabase = getSupabaseExecutable();
  const output = await runCommand(
    supabase,
    ["gen", "types", "typescript", "--local", "--schema", "entities", "--schema", "knowledge"],
    {
      cwd: projectRoot,
      captureOutput: true,
    },
  );

  return normalizeGeneratedTypes(output);
}

async function writeAtomically(filePath: string, contents: string): Promise<void> {
  const temporaryPath = `${filePath}.${randomBytes(8).toString("hex")}.tmp`;

  try {
    await writeFile(temporaryPath, contents, "utf8");
    await rename(temporaryPath, filePath);
  } catch (error) {
    await unlink(temporaryPath).catch(() => undefined);
    throw error;
  }
}

async function checkGeneratedTypes(generated: string): Promise<void> {
  let existing: string;

  try {
    existing = await readFile(outputPath, "utf8");
  } catch {
    throw new Error(
      `${path.relative(projectRoot, outputPath)} is missing. Run \`pnpm run db:types\`.`,
    );
  }

  if (existing !== generated) {
    throw new Error(
      `${path.relative(projectRoot, outputPath)} is out of date. Run \`pnpm run db:types\`.`,
    );
  }
}

async function main(): Promise<void> {
  const checkOnly = process.argv.includes("--check");

  try {
    const generated = await generateDatabaseTypes();

    if (checkOnly) {
      await checkGeneratedTypes(generated);
      return;
    }

    await writeAtomically(outputPath, generated);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  }
}

void main();
