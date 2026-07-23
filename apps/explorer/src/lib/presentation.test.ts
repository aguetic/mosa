import { describe, expect, it } from "vitest";
import { formatDate, formatLiteralValue, isHttpReference, literalLabel } from "./presentation";
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
    objectPlaceKind: null,
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

describe("formatLiteralValue", () => {
  it("formats approximate date intervals for presentation", () => {
    expect(
      formatLiteralValue({
        type: "date_interval",
        earliest: "1000",
        latest: "1200",
        precision: "year",
        interpretation: "approximate_range",
        verbatim: "1000–1200 (approx)",
      }),
    ).toBe("Approximately 1000–1200");
  });

  it("formats exact ranges and text values", () => {
    expect(
      formatLiteralValue({
        type: "date_interval",
        earliest: "1868",
        latest: "1869",
        interpretation: "range",
      }),
    ).toBe("1868–1869");
    expect(formatLiteralValue({ type: "text", value: "basalt" })).toBe("basalt");
  });
});

describe("literalLabel", () => {
  it("prefers the display value when present", () => {
    expect(literalLabel(claim({ literalDisplayValue: "Moai" }))).toBe("Moai");
  });

  it("formats date intervals instead of raw JSON", () => {
    expect(
      literalLabel(
        claim({
          predicate: "made_during",
          literalValue: {
            type: "date_interval",
            earliest: "1000",
            latest: "1200",
            precision: "year",
            interpretation: "approximate_range",
            verbatim: "1000–1200 (approx)",
          },
        }),
      ),
    ).toBe("Approximately 1000–1200");
  });

  it("falls back to string and JSON literals", () => {
    expect(literalLabel(claim({ literalValue: "plain" }))).toBe("plain");
    expect(literalLabel(claim({ literalValue: { type: "text", value: "x" } }))).toBe("x");
    expect(literalLabel(claim({ literalValue: { unexpected: true } }))).toBe('{"unexpected":true}');
  });

  it("labels missing literals", () => {
    expect(literalLabel(claim({ literalValue: null }))).toBe("Empty literal");
  });
});
