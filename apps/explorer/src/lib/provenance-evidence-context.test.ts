import { describe, expect, it } from "vitest";
import type { ProvenanceEvidence, ProvenanceStatement } from "./provenance";
import { groupProvenanceStatementsByEvidenceContext } from "./provenance-evidence-context";

function evidence(
  id: string,
  excerpt: string | null,
  options: { locator?: string; sourceId?: string } = {},
): ProvenanceEvidence {
  return {
    id,
    sourceId: options.sourceId ?? "source-wikipedia",
    sourceLabel: "Wikipedia snapshot: Rongorongo text C",
    relationship: "supports",
    locator: options.locator ?? "Provenance history paragraph",
    excerpt,
    notes: null,
  };
}

function statement(
  id: string,
  predicate: string,
  statementEvidence: ProvenanceEvidence[],
): ProvenanceStatement {
  return {
    id,
    subjectId: "event-paris",
    subjectLabel: "Mamari deposit in the Missionary Museum, Paris",
    predicate,
    valueKind: "entity",
    objectEntityId: `value-${id}`,
    objectEntityLabel: `Value ${id}`,
    objectEntityType: "agent",
    literalValue: null,
    literalDisplayValue: null,
    literalLanguage: null,
    assertedByAgentId: "wikipedia-contributors",
    assertedByLabel: "Wikipedia contributors",
    status: "active",
    notes: null,
    evidence: statementEvidence,
  };
}

describe("groupProvenanceStatementsByEvidenceContext", () => {
  it("groups claims that share an exact source, locator, and non-empty excerpt", () => {
    const sharedExcerpt = "deposited in the Missionary Museum";
    const statements = [
      statement("item", "moved_item", [evidence("e-item", sharedExcerpt)]),
      statement("recipient", "transferred_to", [evidence("e-recipient", sharedExcerpt)]),
      statement("location", "occurred_at", [evidence("e-location", null)]),
    ];

    const result = groupProvenanceStatementsByEvidenceContext(statements);

    expect(result.groups).toHaveLength(1);
    expect(result.groups[0]?.label).toBe("Reported together");
    expect(result.groups[0]?.statements.map(({ id }) => id)).toEqual(["item", "recipient"]);
    expect(result.ungrouped.map(({ id }) => id)).toEqual(["location"]);
  });

  it("keeps the Jaussen–1888 and French Navy–1892 pairs in separate Reported together groups", () => {
    const jaussenExcerpt = "either by Jaussen in 1888";
    const navyExcerpt = "or by the French navy in 1892 after his death";
    const statements = [
      statement("jaussen", "carried_out_by", [evidence("e-jaussen", jaussenExcerpt)]),
      statement("1888", "occurred_during", [evidence("e-1888", jaussenExcerpt)]),
      statement("navy", "carried_out_by", [evidence("e-navy", navyExcerpt)]),
      statement("1892", "occurred_during", [evidence("e-1892", navyExcerpt)]),
      statement("paris", "occurred_at", [evidence("e-paris", null)]),
    ];

    const result = groupProvenanceStatementsByEvidenceContext(statements);

    expect(result.groups.map(({ label }) => label)).toEqual([
      "Reported together",
      "Reported together",
    ]);
    expect(result.groups.map(({ statements: grouped }) => grouped.map(({ id }) => id))).toEqual([
      ["jaussen", "1888"],
      ["navy", "1892"],
    ]);
    expect(result.ungrouped.map(({ id }) => id)).toEqual(["paris"]);
  });

  it("leaves claims with no excerpt, a unique context, or multiple candidate contexts ungrouped", () => {
    const shared = "shared excerpt";
    const other = "other excerpt";
    const statements = [
      statement("no-excerpt", "occurred_at", [evidence("e-none", null)]),
      statement("unique", "described_as", [evidence("e-unique", "only this claim")]),
      statement("ambiguous", "moved_item", [
        evidence("e-shared-a", shared),
        evidence("e-other-a", other),
      ]),
      statement("shared-partner", "transferred_to", [evidence("e-shared-b", shared)]),
      statement("other-partner", "carried_out_by", [evidence("e-other-b", other)]),
      statement("pair-a", "carried_out_by", [evidence("e-pair-a", "pair excerpt")]),
      statement("pair-b", "occurred_during", [evidence("e-pair-b", "pair excerpt")]),
    ];

    const result = groupProvenanceStatementsByEvidenceContext(statements);

    expect(result.groups.map(({ statements: grouped }) => grouped.map(({ id }) => id))).toEqual([
      ["pair-a", "pair-b"],
    ]);
    expect(result.ungrouped.map(({ id }) => id)).toEqual([
      "no-excerpt",
      "unique",
      "ambiguous",
      "shared-partner",
      "other-partner",
    ]);
  });

  it("does not group claims when source_id, locator, or excerpt differ", () => {
    const excerpt = "same excerpt text";
    const statements = [
      statement("source-a", "moved_item", [evidence("e1", excerpt, { sourceId: "source-a" })]),
      statement("source-b", "transferred_to", [evidence("e2", excerpt, { sourceId: "source-b" })]),
      statement("locator-a", "carried_out_by", [
        evidence("e3", excerpt, { locator: "Paragraph A" }),
      ]),
      statement("locator-b", "occurred_during", [
        evidence("e4", excerpt, { locator: "Paragraph B" }),
      ]),
      statement("excerpt-a", "moved_item", [evidence("e5", "excerpt A")]),
      statement("excerpt-b", "transferred_to", [evidence("e6", "excerpt B")]),
    ];

    const result = groupProvenanceStatementsByEvidenceContext(statements);

    expect(result.groups).toEqual([]);
    expect(result.ungrouped.map(({ id }) => id)).toEqual([
      "source-a",
      "source-b",
      "locator-a",
      "locator-b",
      "excerpt-a",
      "excerpt-b",
    ]);
  });
});
