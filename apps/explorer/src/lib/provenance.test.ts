import { describe, expect, it } from "vitest";
import type { ProvenanceEvent, ProvenanceStatement } from "./provenance";
import { orderProvenanceEvents, provenanceStatementValue } from "./provenance-presentation";

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

function event(
  id: string,
  workingLabel: string,
  statements: ProvenanceStatement[] = [],
): ProvenanceEvent {
  return {
    id,
    workingLabel,
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

describe("orderProvenanceEvents", () => {
  it("orders a partial sequence with alternative predecessors", () => {
    const roussel = event("rous", "Roussel account");
    const zumbohm = event("zumb", "Zumbohm account");
    const tahiti = event("tahi", "Tahiti receipt", [
      statement({
        subjectId: "tahi",
        predicate: "preceded_by",
        valueKind: "entity",
        objectEntityId: "rous",
      }),
      statement({
        subjectId: "tahi",
        predicate: "preceded_by",
        valueKind: "entity",
        objectEntityId: "zumb",
      }),
    ]);
    const paris = event("pari", "Paris deposit", [
      statement({
        subjectId: "pari",
        predicate: "preceded_by",
        valueKind: "entity",
        objectEntityId: "tahi",
      }),
    ]);

    expect(orderProvenanceEvents([paris, tahiti, zumbohm, roussel]).map(({ id }) => id)).toEqual([
      "rous",
      "zumb",
      "tahi",
      "pari",
    ]);
  });

  it("returns every event when the source claims contain a cycle", () => {
    const first = event("a", "A", [
      statement({
        subjectId: "a",
        predicate: "preceded_by",
        valueKind: "entity",
        objectEntityId: "b",
      }),
    ]);
    const second = event("b", "B", [
      statement({
        subjectId: "b",
        predicate: "preceded_by",
        valueKind: "entity",
        objectEntityId: "a",
      }),
    ]);

    expect(orderProvenanceEvents([second, first]).map(({ id }) => id)).toEqual(["a", "b"]);
  });
});
