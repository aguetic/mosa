import { describe, expect, it } from "vitest";
import { isUuid, parseIdentifiers } from "./values";

describe("isUuid", () => {
  it("accepts canonical UUID strings", () => {
    expect(isUuid("30000000-0000-4000-8000-000000000001")).toBe(true);
    expect(isUuid("550e8400-e29b-41d4-a716-446655440000")).toBe(true);
  });

  it("rejects malformed identifiers", () => {
    expect(isUuid("not-a-uuid")).toBe(false);
    expect(isUuid("30000000-0000-4000-8000-00000000000")).toBe(false);
    expect(isUuid("30000000-0000-6000-8000-000000000001")).toBe(false);
  });
});

describe("parseIdentifiers", () => {
  it("maps well-formed identifier objects", () => {
    expect(
      parseIdentifiers([
        {
          namespace: "british-museum",
          value: "Oc1869,1005.1",
          source_id: "40000000-0000-4000-8000-000000000001",
          source_label: "British Museum catalogue",
        },
      ]),
    ).toEqual([
      {
        namespace: "british-museum",
        value: "Oc1869,1005.1",
        sourceId: "40000000-0000-4000-8000-000000000001",
        sourceLabel: "British Museum catalogue",
      },
    ]);
  });

  it("ignores malformed JSON payloads", () => {
    expect(parseIdentifiers(null)).toEqual([]);
    expect(parseIdentifiers("[]")).toEqual([]);
    expect(
      parseIdentifiers([
        null,
        12,
        { namespace: 1, value: "x" },
        { namespace: "ok", value: "y", source_id: 3 },
      ]),
    ).toEqual([
      {
        namespace: "ok",
        value: "y",
        sourceId: null,
        sourceLabel: null,
      },
    ]);
  });
});
