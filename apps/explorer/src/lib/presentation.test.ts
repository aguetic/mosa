import { describe, expect, it } from "vitest";
import { formatDate, isHttpReference, literalLabel } from "./presentation";
import type { ClaimDetail } from "./queries";

function claim(overrides: Partial<ClaimDetail> = {}): ClaimDetail {
  return {
    id: "50000000-0000-4000-8000-000000000001",
    subjectId: "30000000-0000-4000-8000-000000000001",
    subjectLabel: "Hoa Hakananaiʻa",
    subjectType: "item",
    predicate: "has_name",
    valueKind: "literal",
    objectEntityId: null,
    objectEntityLabel: null,
    objectEntityType: null,
    literalValue: null,
    literalDisplayValue: null,
    literalLanguage: null,
    assertedByAgentId: null,
    assertedByLabel: null,
    status: "active",
    supersedesClaimId: null,
    notes: null,
    createdAt: "2026-01-01T00:00:00.000Z",
    evidence: [],
    ...overrides,
  };
}

describe("formatDate", () => {
  it("returns null for empty values", () => {
    expect(formatDate(null)).toBeNull();
  });

  it("formats valid dates in en-GB UTC", () => {
    expect(formatDate("2026-07-17T12:00:00.000Z")).toBe("17 Jul 2026, 12:00");
  });

  it("returns the original string for invalid dates", () => {
    expect(formatDate("not-a-date")).toBe("not-a-date");
  });
});

describe("isHttpReference", () => {
  it("accepts http and https URLs", () => {
    expect(isHttpReference("https://example.org/record")).toBe(true);
    expect(isHttpReference("http://example.org/record")).toBe(true);
  });

  it("rejects non-http references and empty values", () => {
    expect(isHttpReference(null)).toBe(false);
    expect(isHttpReference("")).toBe(false);
    expect(isHttpReference("ftp://example.org")).toBe(false);
    expect(isHttpReference("not a url")).toBe(false);
  });
});

describe("literalLabel", () => {
  it("prefers the display value when present", () => {
    expect(literalLabel(claim({ literalDisplayValue: "Moai" }))).toBe("Moai");
  });

  it("falls back to string and JSON literals", () => {
    expect(literalLabel(claim({ literalValue: "plain" }))).toBe("plain");
    expect(literalLabel(claim({ literalValue: { type: "text", value: "x" } }))).toBe(
      '{"type":"text","value":"x"}',
    );
  });

  it("labels missing literals", () => {
    expect(literalLabel(claim({ literalValue: null }))).toBe("Empty literal");
  });
});
