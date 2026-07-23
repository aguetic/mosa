import { describe, expect, it } from "vitest";
import type { ProvenanceEvent, ProvenanceStatement } from "./provenance";
import {
  generateProvenanceEventTitle,
  orderProvenanceEvents,
  provenanceStatementValue,
  summarizeProvenanceEvent,
} from "./provenance-presentation";

function statement(overrides: Partial<ProvenanceStatement> = {}): ProvenanceStatement {
  return {
    id: "claim",
    subjectId: "subject",
    subjectLabel: "Subject",
    predicate: "described_as",
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
    notes: null,
    evidence: [],
    ...overrides,
  };
}

function entityStatement(
  predicate: string,
  id: string,
  label: string,
  entityType = "agent",
): ProvenanceStatement {
  return statement({
    id: `${predicate}-${id}`,
    predicate,
    valueKind: "entity",
    objectEntityId: id,
    objectEntityLabel: label,
    objectEntityType: entityType,
  });
}

function event(id: string, statements: ProvenanceStatement[] = []): ProvenanceEvent {
  return {
    id,
    eventKind: "unknown",
    notes: null,
    statements,
  };
}

describe("provenanceStatementValue", () => {
  it("prefers source verbatim date wording", () => {
    expect(
      provenanceStatementValue(
        statement({
          literalValue: {
            type: "date_interval",
            earliest: "1888",
            latest: "1892",
            alternatives: ["1888", "1892"],
            verbatim: "1888 or 1892",
          },
        }),
      ),
    ).toBe("1888 or 1892");
  });

  it("uses an entity label for entity-valued statements", () => {
    expect(
      provenanceStatementValue(
        statement({
          valueKind: "entity",
          objectEntityId: "agent-id",
          objectEntityLabel: "Tepano Jaussen",
        }),
      ),
    ).toBe("Tepano Jaussen");
  });
});

describe("generateProvenanceEventTitle", () => {
  it("uses transfer source and recipient", () => {
    expect(
      generateProvenanceEventTitle(
        event("e1", [
          entityStatement("transferred_from", "a", "New Zealand Government"),
          entityStatement("transferred_to", "b", "Te Papa"),
        ]),
      ),
    ).toBe("Transfer from New Zealand Government to Te Papa");
  });

  it("uses movement origin and destination", () => {
    expect(
      generateProvenanceEventTitle(
        event("e1", [
          entityStatement("moved_from", "a", "Rapa Nui", "place"),
          entityStatement("moved_to", "b", "Tahiti", "place"),
        ]),
      ),
    ).toBe("Movement from Rapa Nui to Tahiti");
  });

  it("uses arrival when only destination is known", () => {
    expect(
      generateProvenanceEventTitle(
        event("e1", [entityStatement("moved_to", "a", "England", "place")]),
      ),
    ).toBe("Arrival in England");
  });

  it("uses holding agent", () => {
    expect(
      generateProvenanceEventTitle(
        event("e1", [entityStatement("holding_agent", "a", "Oldman Collection")]),
      ),
    ).toBe("Held by Oldman Collection");
  });

  it("falls back to Provenance event when no recognised predicates exist", () => {
    expect(
      generateProvenanceEventTitle(
        event("e1", [entityStatement("moved_item", "item", "An item", "item")]),
      ),
    ).toBe("Provenance event");
  });
});

describe("summarizeProvenanceEvent dates and notices", () => {
  it("summarises an exact date", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [
        statement({
          predicate: "occurred_during",
          literalValue: {
            earliest: "1992",
            latest: "1992",
            verbatim: "1992",
            interpretation: "exact",
          },
        }),
      ]),
    );

    expect(summary.dateLabel).toBe("1992");
    expect(summary.sortStart).toBe("1992");
    expect(summary.sortEnd).toBe("1992");
    expect(summary.dateCategory).toBe("dated");
    expect(summary.notices).not.toContain("Approximate date");
  });

  it("preserves approximate dates with a notice", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [
        statement({
          predicate: "occurred_during",
          literalValue: {
            earliest: "1870",
            latest: "1870",
            verbatim: "around 1870",
            interpretation: "approximate",
          },
        }),
      ]),
    );

    expect(summary.dateLabel).toBe("around 1870");
    expect(summary.notices).toContain("Approximate date");
  });

  it("preserves alternative dates without collapsing them to a range", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [
        statement({
          predicate: "occurred_during",
          literalValue: {
            earliest: "1828",
            latest: "1835",
            verbatim: "1828 or 1835",
            alternatives: ["1828", "1835"],
            interpretation: "alternatives",
          },
        }),
      ]),
    );

    expect(summary.dateLabel).toBe("1828 or 1835");
    expect(summary.sortStart).toBe("1828");
    expect(summary.sortEnd).toBe("1835");
    expect(summary.notices).toContain("Alternative dates reported");
  });

  it("marks events without dates as undated", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [entityStatement("holding_agent", "a", "Oldman Collection")]),
    );

    expect(summary.dateLabel).toBe("Date not recorded");
    expect(summary.dateCategory).toBe("undated");
    expect(summary.notices).toContain("Date not recorded");
  });

  it("adds qualification and contradiction notices from evidence relationships", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [
        statement({
          id: "claim-1",
          predicate: "carried_out_by",
          valueKind: "entity",
          objectEntityId: "exp",
          objectEntityLabel: "HMS Blossom expedition",
          objectEntityType: "agent",
          evidence: [
            {
              id: "ev-1",
              sourceId: "src",
              sourceLabel: "Catalogue",
              relationship: "qualifies",
              locator: null,
              excerpt: null,
              notes: null,
            },
            {
              id: "ev-2",
              sourceId: "src",
              sourceLabel: "Catalogue",
              relationship: "contradicts",
              locator: null,
              excerpt: null,
              notes: null,
            },
          ],
        }),
      ]),
    );

    expect(summary.notices).toContain("Source includes a qualification");
    expect(summary.notices).toContain("Conflicting evidence");
  });

  it("deduplicates notices", () => {
    const summary = summarizeProvenanceEvent(
      event("e1", [
        statement({
          predicate: "occurred_during",
          literalValue: {
            earliest: "1828",
            latest: "1835",
            verbatim: "1828 or 1835",
            alternatives: ["1828", "1835"],
            interpretation: "alternatives",
          },
          evidence: [
            {
              id: "ev-1",
              sourceId: "src",
              sourceLabel: "Catalogue",
              relationship: "qualifies",
              locator: null,
              excerpt: null,
              notes: null,
            },
          ],
        }),
        statement({
          id: "claim-2",
          predicate: "moved_to",
          valueKind: "entity",
          objectEntityId: "england",
          objectEntityLabel: "England",
          objectEntityType: "place",
          evidence: [
            {
              id: "ev-2",
              sourceId: "src",
              sourceLabel: "Catalogue",
              relationship: "qualifies",
              locator: null,
              excerpt: null,
              notes: null,
            },
          ],
        }),
      ]),
    );

    expect(
      summary.notices.filter((notice) => notice === "Source includes a qualification"),
    ).toHaveLength(1);
    expect(
      summary.notices.filter((notice) => notice === "Alternative dates reported"),
    ).toHaveLength(1);
  });
});

describe("orderProvenanceEvents", () => {
  it("orders dated events before undated events and by sort bounds", () => {
    const undated = event("u", [entityStatement("holding_agent", "a", "Oldman Collection")]);
    const later = event("b", [
      statement({
        predicate: "occurred_during",
        literalValue: {
          earliest: "1992",
          latest: "1992",
          verbatim: "1992",
          interpretation: "exact",
        },
      }),
    ]);
    const earlier = event("a", [
      statement({
        predicate: "occurred_during",
        literalValue: {
          earliest: "1825",
          latest: "1825",
          verbatim: "1825",
          interpretation: "exact",
        },
      }),
    ]);

    expect(orderProvenanceEvents([undated, later, earlier]).map(({ id }) => id)).toEqual([
      "a",
      "b",
      "u",
    ]);
  });

  it("uses event UUID as a deterministic technical tie-breaker", () => {
    const date = {
      earliest: "1888",
      latest: "1888",
      verbatim: "1888",
      interpretation: "exact",
    };
    const first = event("aaa", [statement({ predicate: "occurred_during", literalValue: date })]);
    const second = event("bbb", [statement({ predicate: "occurred_during", literalValue: date })]);

    expect(orderProvenanceEvents([second, first]).map(({ id }) => id)).toEqual(["aaa", "bbb"]);
  });

  it("orders by date and UUID without depending on incidental labels", () => {
    const sharedStatements = [
      entityStatement("moved_to", "england", "England", "place"),
      statement({
        predicate: "occurred_during",
        literalValue: {
          earliest: "1828",
          latest: "1835",
          verbatim: "1828 or 1835",
          alternatives: ["1828", "1835"],
          interpretation: "alternatives",
        },
      }),
    ];
    const first = event("event-a", sharedStatements);
    const second = event("event-b", sharedStatements);

    const ordered = orderProvenanceEvents([second, first]);
    expect(ordered.map(({ id }) => id)).toEqual(["event-a", "event-b"]);
    expect(ordered.map((item) => generateProvenanceEventTitle(item))).toEqual([
      "Arrival in England",
      "Arrival in England",
    ]);
  });
});
