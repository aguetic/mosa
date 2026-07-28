import path from "node:path";
import { parseArgs } from "node:util";
import { runImport } from "./lib/object-dossier/import";
import { readPacketFile } from "./lib/object-dossier/packet";
import { formatOutcome } from "./lib/object-dossier/report";
import { validatePacket } from "./lib/object-dossier/validate";
import { getLocalDatabaseUrl } from "./lib/supabase-local";

const projectRoot = path.resolve(__dirname, "..");

const USAGE = `Usage: tsx scripts/import-object-dossier.ts <packet.json> [options]

Validates an object dossier packet and, by default, reports a dry-run
import plan without writing anything.

Options:
  --check               Validate the packet only; do not connect to a database.
  --apply               Write the packet to the database in one transaction.
  --database-url <url>  Target database. Defaults to LOCAL_DATABASE_URL,
                        SUPABASE_DB_URL or the local Supabase stack.
  --help                Show this message.
`;

async function main(): Promise<void> {
  const { values, positionals } = parseArgs({
    args: process.argv.slice(2),
    allowPositionals: true,
    options: {
      check: { type: "boolean", default: false },
      apply: { type: "boolean", default: false },
      "database-url": { type: "string" },
      help: { type: "boolean", default: false },
    },
  });

  if (values.help) {
    process.stdout.write(USAGE);
    return;
  }

  const packetArgument = positionals[0];
  if (!packetArgument) {
    process.stderr.write(USAGE);
    process.exitCode = 1;
    return;
  }

  if (values.check && values.apply) {
    process.stderr.write("error: --check and --apply are mutually exclusive.\n");
    process.exitCode = 1;
    return;
  }

  const packetPath = path.resolve(process.cwd(), packetArgument);
  const raw = await readPacketFile(packetPath);
  const validation = validatePacket(raw);

  if (validation.errors.length > 0 || !validation.packet) {
    process.stderr.write(`Packet ${packetPath} is invalid:\n`);
    for (const error of validation.errors) {
      process.stderr.write(`  - ${error}\n`);
    }
    process.exitCode = 1;
    return;
  }

  if (values.check) {
    process.stdout.write(`Packet ${packetPath} is valid.\n`);
    return;
  }

  const databaseUrl = values["database-url"] ?? (await getLocalDatabaseUrl(projectRoot));
  const outcome = await runImport(validation.packet, {
    databaseUrl,
    apply: values.apply,
  });

  process.stdout.write(`${formatOutcome(outcome)}\n`);
}

if (require.main === module) {
  main().catch((error: unknown) => {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`error: ${message}\n`);
    process.exitCode = 1;
  });
}
