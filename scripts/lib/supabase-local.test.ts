import { describe, expect, it } from "vitest";
import { parseEnvironmentOutput } from "./supabase-local";

describe("parseEnvironmentOutput", () => {
  it("parses KEY=VALUE lines and ignores comments and blanks", () => {
    const values = parseEnvironmentOutput(`
# comment
DB_URL=postgres://localhost:54322/postgres
EMPTY=

QUOTED="hello world"
SINGLE='scoped'
INVALID
=novalue
`);

    expect(values.get("DB_URL")).toBe("postgres://localhost:54322/postgres");
    expect(values.get("EMPTY")).toBe("");
    expect(values.get("QUOTED")).toBe("hello world");
    expect(values.get("SINGLE")).toBe("scoped");
    expect(values.has("INVALID")).toBe(false);
    expect(values.has("")).toBe(false);
  });

  it("keeps values that contain additional equals signs", () => {
    const values = parseEnvironmentOutput("TOKEN=a=b=c");
    expect(values.get("TOKEN")).toBe("a=b=c");
  });
});
