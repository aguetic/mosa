import { describe, expect, it } from "vitest";
import {
  buildDirectDatabaseUrl,
  injectPasswordIntoDatabaseUrl,
  parseEnvironmentOutput,
} from "./supabase-local";

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

describe("injectPasswordIntoDatabaseUrl", () => {
  it("injects a password into a passwordless pooler URL", () => {
    const url = injectPasswordIntoDatabaseUrl(
      "postgresql://postgres.abc@aws-0-eu-central-1.pooler.supabase.com:5432/postgres",
      "s3cret!",
    );

    const parsed = new URL(url);
    expect(parsed.username).toBe("postgres.abc");
    expect(parsed.password).toBe("s3cret!");
    expect(parsed.hostname).toBe("aws-0-eu-central-1.pooler.supabase.com");
    expect(parsed.pathname).toBe("/postgres");
  });

  it("percent-encodes reserved password characters", () => {
    const url = injectPasswordIntoDatabaseUrl(
      "postgresql://postgres.abc@aws-0-eu-central-1.pooler.supabase.com:5432/postgres",
      "p@ss/word:x",
    );

    expect(url).toContain("://postgres.abc:p%40ss%2Fword%3Ax@");
  });

  it("replaces an existing password", () => {
    const url = injectPasswordIntoDatabaseUrl(
      "postgresql://postgres:old@db.example.supabase.co:5432/postgres",
      "new",
    );

    expect(url).toBe("postgresql://postgres:new@db.example.supabase.co:5432/postgres");
  });
});

describe("buildDirectDatabaseUrl", () => {
  it("builds the direct db.<ref>.supabase.co URL", () => {
    expect(buildDirectDatabaseUrl("abcdefghijklmnop", "pw")).toBe(
      "postgresql://postgres:pw@db.abcdefghijklmnop.supabase.co:5432/postgres",
    );
  });
});
