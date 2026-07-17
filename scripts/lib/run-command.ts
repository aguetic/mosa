import { spawn } from "node:child_process";

export interface RunCommandOptions {
  cwd?: string;
  captureOutput?: boolean;
  env?: NodeJS.ProcessEnv;
}

export class CommandError extends Error {
  readonly command: string;
  readonly exitCode: number | null;
  readonly stderr: string;

  constructor(command: string, exitCode: number | null, stderr: string) {
    const suffix = stderr.trim() ? `\n${stderr.trim()}` : "";
    super(`Command failed (${exitCode ?? "unknown"}): ${command}${suffix}`);
    this.name = "CommandError";
    this.command = command;
    this.exitCode = exitCode;
    this.stderr = stderr;
  }
}

export async function runCommand(
  executable: string,
  args: readonly string[],
  options: RunCommandOptions = {},
): Promise<string> {
  const displayCommand = [executable, ...args].join(" ");
  const captureOutput = options.captureOutput ?? false;

  return await new Promise<string>((resolve, reject) => {
    const child = spawn(executable, [...args], {
      cwd: options.cwd,
      env: {
        ...process.env,
        ...options.env,
      },
      shell: false,
      stdio: captureOutput ? ["ignore", "pipe", "pipe"] : "inherit",
    });

    let stdout = "";
    let stderr = "";

    if (captureOutput) {
      child.stdout?.setEncoding("utf8");
      child.stderr?.setEncoding("utf8");
      child.stdout?.on("data", (chunk: string) => {
        stdout += chunk;
      });
      child.stderr?.on("data", (chunk: string) => {
        stderr += chunk;
      });
    }

    child.once("error", (error) => {
      if ((error as NodeJS.ErrnoException).code === "ENOENT") {
        reject(
          new Error(
            `Unable to run ${executable}. Ensure project dependencies are installed and the command is available on PATH.`,
          ),
        );
        return;
      }

      reject(error);
    });

    child.once("close", (exitCode) => {
      if (exitCode === 0) {
        resolve(stdout.trim());
        return;
      }

      reject(new CommandError(displayCommand, exitCode, stderr));
    });
  });
}
