import { describe, expect, it } from "vitest";
import type {
  RestitutionCaseAction,
  RestitutionCaseDetail,
  RestitutionCaseDocument,
  RestitutionCaseParty,
  RestitutionCaseSummary,
  RestitutionDate,
  RestitutionLinkedDocument,
} from "./restitution";
import {
  formatRestitutionDate,
  restitutionCaseDetailView,
  summarizeRestitutionCase,
} from "./restitution-presentation";

function date(
  start: string | null,
  end: string | null = start,
  precision: string | null = start ? "day" : null,
): RestitutionDate {
  return { start, end, precision };
}

function summary(overrides: Partial<RestitutionCaseSummary> = {}): RestitutionCaseSummary {
  return {
    id: "91000000-0000-4000-8000-000000000001",
    reference: "RST-001",
    title: "Return of the Aberdeen Head of an Oba",
    status: "closed",
    ...overrides,
  };
}

function party(overrides: Partial<RestitutionCaseParty> = {}): RestitutionCaseParty {
  return {
    id: "party",
    agentId: "agent",
    agentLabel: "University of Aberdeen",
    role: "initiator",
    ...overrides,
  };
}

function linkedDocument(
  overrides: Partial<RestitutionLinkedDocument> = {},
): RestitutionLinkedDocument {
  return {
    id: "document",
    sourceId: "source",
    sourceLabel: "University announcement",
    documentRole: "decision_announcement",
    relationship: null,
    ...overrides,
  };
}

function action(overrides: Partial<RestitutionCaseAction> = {}): RestitutionCaseAction {
  return {
    id: "action",
    sequenceNumber: 1,
    actionKind: "outreach",
    description: "Discussions began.",
    occurred: date("2020-01-01", "2020-12-31", "year"),
    parties: [],
    documents: [],
    ...overrides,
  };
}

function document(overrides: Partial<RestitutionCaseDocument> = {}): RestitutionCaseDocument {
  return {
    id: "document",
    sourceId: "source",
    sourceLabel: "General process report",
    documentRole: "process_account",
    ...overrides,
  };
}

function detail(overrides: Partial<RestitutionCaseDetail> = {}): RestitutionCaseDetail {
  return {
    id: "91000000-0000-4000-8000-000000000001",
    reference: "RST-001",
    title: "Return of the Aberdeen Head of an Oba",
    status: "closed",
    opened: date("2020-01-01", "2020-12-31", "year"),
    closed: date("2022-02-19", "2022-02-19", "day"),
    items: [
      {
        itemId: "36000000-0000-4000-8000-000000000001",
        itemLabel: "Head of an Oba — University of Aberdeen",
      },
    ],
    parties: [
      party(),
      party({
        id: "party-2",
        agentId: "agent-2",
        agentLabel: "Federal Ministry",
        role: "requester",
      }),
      party({
        id: "party-3",
        agentId: "agent-3",
        agentLabel: "NCMM",
        role: "recipient",
      }),
      party({
        id: "party-4",
        agentId: "agent-4",
        agentLabel: "Royal Court",
        role: "recipient",
      }),
    ],
    actions: [
      action(),
      action({
        id: "action-2",
        sequenceNumber: 2,
        actionKind: "request",
        description: "Formal claim received.",
        occurred: date(null, null, null),
        parties: [
          {
            id: "ap-1",
            agentId: "agent-2",
            agentLabel: "Federal Ministry",
            role: "actor",
          },
        ],
        documents: [linkedDocument()],
      }),
    ],
    otherDocuments: [document()],
    ...overrides,
  };
}

describe("formatRestitutionDate", () => {
  it("formats year-level dates", () => {
    expect(formatRestitutionDate(date("2020-01-01", "2020-12-31", "year"))).toBe("2020");
  });

  it("formats exact day dates", () => {
    expect(formatRestitutionDate(date("2022-02-19", "2022-02-19", "day"))).toBe("19 February 2022");
  });

  it("formats month-level dates", () => {
    expect(formatRestitutionDate(date("2021-03-01", "2021-03-31", "month"))).toBe("March 2021");
  });

  it("keeps unknown dates unknown", () => {
    expect(formatRestitutionDate(date(null, null, null))).toBe("Date unrecorded");
  });
});

describe("summarizeRestitutionCase", () => {
  it("builds a connection-only item-page summary", () => {
    expect(summarizeRestitutionCase(summary())).toEqual({
      caseId: "91000000-0000-4000-8000-000000000001",
      reference: "RST-001",
      title: "Return of the Aberdeen Head of an Oba",
      statusLabel: "Closed",
      href: "/restitution/cases/91000000-0000-4000-8000-000000000001",
    });
  });
});

describe("restitutionCaseDetailView", () => {
  it("groups parties by role and nests documents under actions", () => {
    const view = restitutionCaseDetailView(detail());

    expect(view.title).toBe("Return of the Aberdeen Head of an Oba");
    expect(view.statusLabel).toBe("Closed");
    expect(view.items[0]?.href).toBe("/entities/36000000-0000-4000-8000-000000000001");
    expect(view.partyGroups.map((group) => group.roleLabel)).toEqual([
      "Initiator",
      "Requester",
      "Recipient",
    ]);
    expect(view.partyGroups.find((group) => group.role === "recipient")?.parties).toHaveLength(2);
    expect(view.actions.map((entry) => entry.kindLabel)).toEqual(["Outreach", "Request"]);
    expect(view.actions[1]?.dateLabel).toBe("Date unrecorded");
    expect(view.actions[1]?.documents).toEqual([
      {
        roleLabel: "Decision Announcement",
        sourceId: "source",
        sourceLabel: "University announcement",
        sourceHref: "/entities/source",
        relationshipLabel: null,
      },
    ]);
    expect(view.otherDocuments).toEqual([
      {
        roleLabel: "Process Account",
        sourceId: "source",
        sourceLabel: "General process report",
        sourceHref: "/entities/source",
        relationshipLabel: null,
      },
    ]);
  });
});
