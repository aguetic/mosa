import { describe, expect, it } from "vitest";
import { currentStateClaimLabel, itemPageView, originClaimLabel } from "./object-presentation";
import { buildItemSummary } from "./object-summary";
import type { ClaimDetail } from "./queries";
import type { RestitutionItemDocument } from "./restitution";

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
    literalValue: { type: "text", value: "Hoa Hakananaiʻa", language: "en" },
    literalDisplayValue: "Hoa Hakananaiʻa",
    literalLanguage: "en",
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

const ITEM_ID = "30000000-0000-4000-8000-000000000001";

describe("buildItemSummary", () => {
  it("groups origin and current-state claims ahead of remaining claims", () => {
    const summary = buildItemSummary({
      itemId: ITEM_ID,
      claims: [
        claim({
          id: "1",
          predicate: "has_name",
        }),
        claim({
          id: "2",
          predicate: "made_at",
          valueKind: "entity",
          objectEntityId: "place-1",
          objectEntityLabel: "Rano Kao",
          objectEntityType: "place",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
        claim({
          id: "3",
          predicate: "found_at",
          valueKind: "entity",
          objectEntityId: "place-2",
          objectEntityLabel: "Orongo",
          objectEntityType: "place",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
        claim({
          id: "4",
          predicate: "held_by",
          valueKind: "entity",
          objectEntityId: "agent-1",
          objectEntityLabel: "British Museum",
          objectEntityType: "agent",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
        claim({
          id: "5",
          predicate: "made_of",
          literalValue: { type: "text", value: "basalt", language: "en" },
          literalDisplayValue: "basalt",
        }),
      ],
      provenanceEvents: [],
      restitutionCases: [],
      restitutionDocuments: [],
    });

    expect(summary.originClaims.map((row) => row.predicate)).toEqual(["made_at", "found_at"]);
    expect(summary.currentStateClaims.map((row) => row.predicate)).toEqual(["held_by"]);
    expect(summary.remainingOutgoingClaims.map((row) => row.predicate)).toEqual([
      "has_name",
      "made_of",
    ]);
  });

  it("aggregates documents from source links, evidence, identifiers, and restitution", () => {
    const restitutionDocuments: RestitutionItemDocument[] = [
      {
        caseId: "case-1",
        caseReference: "RST-001",
        sourceId: "source-rest",
        sourceLabel: "Handover record",
        documentRole: "handover_record",
      },
    ];

    const summary = buildItemSummary({
      itemId: ITEM_ID,
      claims: [
        claim({
          id: "claim-refers",
          subjectId: "source-ref",
          subjectLabel: "Catalogue record",
          subjectType: "source",
          predicate: "refers_to",
          valueKind: "entity",
          objectEntityId: ITEM_ID,
          objectEntityLabel: "Hoa Hakananaiʻa",
          objectEntityType: "item",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
        claim({
          id: "claim-depicts",
          subjectId: "source-photo",
          subjectLabel: "Photograph",
          subjectType: "source",
          predicate: "depicts",
          valueKind: "entity",
          objectEntityId: ITEM_ID,
          objectEntityLabel: "Hoa Hakananaiʻa",
          objectEntityType: "item",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
        claim({
          id: "claim-held",
          predicate: "held_by",
          valueKind: "entity",
          objectEntityId: "agent-1",
          objectEntityLabel: "British Museum",
          objectEntityType: "agent",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
          evidence: [
            {
              id: "ev-1",
              sourceId: "source-ref",
              sourceLabel: "Catalogue record",
              relationship: "supports",
              locator: "field:held_by",
              excerpt: null,
              notes: null,
            },
          ],
        }),
      ],
      identifiers: [
        {
          namespace: "bm",
          value: "Oc1896,-.123",
          sourceId: "source-ref",
          sourceLabel: "Catalogue record",
        },
      ],
      provenanceEvents: [],
      restitutionCases: [],
      restitutionDocuments,
    });

    expect(summary.documents.map((doc) => doc.sourceLabel)).toEqual([
      "Catalogue record",
      "Handover record",
      "Photograph",
    ]);

    const catalogue = summary.documents.find((doc) => doc.sourceId === "source-ref");
    expect(catalogue?.associations.map((row) => row.kind).sort()).toEqual([
      "evidence",
      "identifier_source",
      "refers_to",
    ]);

    expect(summary.remainingIncomingClaims).toEqual([]);
  });

  it("excludes provenance event-link predicates from remaining incoming claims", () => {
    const summary = buildItemSummary({
      itemId: ITEM_ID,
      claims: [
        claim({
          id: "moved",
          subjectId: "event-1",
          subjectLabel: "Removal",
          subjectType: "event",
          predicate: "moved_item",
          valueKind: "entity",
          objectEntityId: ITEM_ID,
          objectEntityLabel: "Hoa Hakananaiʻa",
          objectEntityType: "item",
          literalValue: null,
          literalDisplayValue: null,
          literalLanguage: null,
        }),
      ],
      provenanceEvents: [],
      restitutionCases: [],
      restitutionDocuments: [],
    });

    expect(summary.remainingIncomingClaims).toEqual([]);
  });
});

describe("itemPageView", () => {
  it("builds empty-state sections for the object hierarchy", () => {
    const view = itemPageView(
      buildItemSummary({
        itemId: ITEM_ID,
        claims: [],
        provenanceEvents: [],
        restitutionCases: [],
        restitutionDocuments: [],
      }),
    );

    expect(view.origin.title).toBe("Origin");
    expect(view.origin.rows).toEqual([]);
    expect(view.origin.emptyText).toBe("No origin recorded.");
    expect(view.documents.emptyText).toBe("No documents recorded.");
    expect(view.provenanceEmptyText).toBe("No provenance events recorded.");
    expect(view.currentState.title).toBe("Current state");
    expect(view.documents.title).toBe("Documents");
  });

  it("labels gallery locations as display locations", () => {
    const locatedAt = claim({
      predicate: "located_at",
      valueKind: "entity",
      objectEntityId: "gallery-1",
      objectEntityLabel: "Room 24",
      objectEntityType: "place",
      objectPlaceKind: "gallery",
      literalValue: null,
      literalDisplayValue: null,
      literalLanguage: null,
    });
    const broader = claim({
      id: "broader",
      predicate: "located_at",
      valueKind: "entity",
      objectEntityId: "place-london",
      objectEntityLabel: "London",
      objectEntityType: "place",
      objectPlaceKind: "city",
      literalValue: null,
      literalDisplayValue: null,
      literalLanguage: null,
    });

    expect(originClaimLabel(claim({ predicate: "made_at" }))).toBe("Made at");
    expect(currentStateClaimLabel(locatedAt, [locatedAt, broader])).toBe("Display location");
    expect(currentStateClaimLabel(broader, [locatedAt, broader])).toBe("Broader location");
  });
});
