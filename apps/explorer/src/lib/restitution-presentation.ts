import type {
  RestitutionCaseAction,
  RestitutionCaseDetail,
  RestitutionCaseDocument,
  RestitutionCaseParty,
  RestitutionCaseSummary,
  RestitutionDate,
  RestitutionLinkedDocument,
} from "./restitution";

export interface RestitutionCaseSummaryView {
  caseId: string;
  reference: string;
  title: string;
  statusLabel: string;
  href: string;
}

export interface RestitutionPartyGroup {
  role: string;
  roleLabel: string;
  parties: Array<{
    agentId: string;
    agentLabel: string;
    href: string;
  }>;
}

export interface RestitutionDocumentView {
  roleLabel: string;
  sourceId: string;
  sourceLabel: string;
  sourceHref: string;
  relationshipLabel: string | null;
}

export interface RestitutionActionView {
  sequenceNumber: number;
  kindLabel: string;
  dateLabel: string;
  description: string;
  parties: Array<{
    roleLabel: string;
    agentId: string;
    agentLabel: string;
    href: string;
  }>;
  documents: RestitutionDocumentView[];
}

export interface RestitutionCaseDetailView {
  reference: string;
  title: string;
  statusLabel: string;
  items: Array<{
    itemId: string;
    itemLabel: string;
    href: string;
  }>;
  partyGroups: RestitutionPartyGroup[];
  actions: RestitutionActionView[];
  otherDocuments: RestitutionDocumentView[];
}

const MONTH_NAMES = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
] as const;

function parseDateParts(value: string): { year: number; month: number; day: number } | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) {
    return null;
  }

  return {
    year: Number(match[1]),
    month: Number(match[2]),
    day: Number(match[3]),
  };
}

function humanizeToken(value: string): string {
  return value
    .split("_")
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

export function formatRestitutionDate(date: RestitutionDate): string {
  if (!date.start || !date.end || !date.precision) {
    return "Date unrecorded";
  }

  const start = parseDateParts(date.start);
  const end = parseDateParts(date.end);
  if (!start || !end) {
    return "Date unrecorded";
  }

  if (date.precision === "year") {
    return start.year === end.year ? String(start.year) : `${start.year}–${end.year}`;
  }

  if (date.precision === "month") {
    const startLabel = `${MONTH_NAMES[start.month - 1]} ${start.year}`;
    const endLabel = `${MONTH_NAMES[end.month - 1]} ${end.year}`;
    return startLabel === endLabel ? startLabel : `${startLabel} – ${endLabel}`;
  }

  if (date.precision === "day") {
    const startLabel = `${start.day} ${MONTH_NAMES[start.month - 1]} ${start.year}`;
    const endLabel = `${end.day} ${MONTH_NAMES[end.month - 1]} ${end.year}`;
    return startLabel === endLabel ? startLabel : `${startLabel} – ${endLabel}`;
  }

  return "Date unrecorded";
}

export function restitutionStatusLabel(status: string): string {
  return humanizeToken(status);
}

export function restitutionRoleLabel(role: string): string {
  return humanizeToken(role);
}

export function restitutionActionKindLabel(actionKind: string): string {
  return humanizeToken(actionKind);
}

export function restitutionDocumentRoleLabel(documentRole: string): string {
  return humanizeToken(documentRole);
}

export function summarizeRestitutionCase(
  summary: RestitutionCaseSummary,
): RestitutionCaseSummaryView {
  return {
    caseId: summary.id,
    reference: summary.reference,
    title: summary.title,
    statusLabel: restitutionStatusLabel(summary.status),
    href: `/restitution/cases/${summary.id}`,
  };
}

function groupParties(parties: RestitutionCaseParty[]): RestitutionPartyGroup[] {
  const groups = new Map<string, RestitutionPartyGroup>();

  for (const party of parties) {
    const existing = groups.get(party.role);
    const entry = {
      agentId: party.agentId,
      agentLabel: party.agentLabel,
      href: `/entities/${party.agentId}`,
    };

    if (existing) {
      existing.parties.push(entry);
      continue;
    }

    groups.set(party.role, {
      role: party.role,
      roleLabel: restitutionRoleLabel(party.role),
      parties: [entry],
    });
  }

  return [...groups.values()];
}

function toDocumentView(
  document: RestitutionCaseDocument | RestitutionLinkedDocument,
): RestitutionDocumentView {
  return {
    roleLabel: restitutionDocumentRoleLabel(document.documentRole),
    sourceId: document.sourceId,
    sourceLabel: document.sourceLabel,
    sourceHref: `/entities/${document.sourceId}`,
    relationshipLabel:
      "relationship" in document && document.relationship
        ? humanizeToken(document.relationship)
        : null,
  };
}

function toActionView(action: RestitutionCaseAction): RestitutionActionView {
  return {
    sequenceNumber: action.sequenceNumber,
    kindLabel: restitutionActionKindLabel(action.actionKind),
    dateLabel: formatRestitutionDate(action.occurred),
    description: action.description,
    parties: action.parties.map((party) => ({
      roleLabel: restitutionRoleLabel(party.role),
      agentId: party.agentId,
      agentLabel: party.agentLabel,
      href: `/entities/${party.agentId}`,
    })),
    documents: action.documents.map(toDocumentView),
  };
}

export function restitutionCaseDetailView(
  detail: RestitutionCaseDetail,
): RestitutionCaseDetailView {
  return {
    reference: detail.reference,
    title: detail.title,
    statusLabel: restitutionStatusLabel(detail.status),
    items: detail.items.map((item) => ({
      itemId: item.itemId,
      itemLabel: item.itemLabel,
      href: `/entities/${item.itemId}`,
    })),
    partyGroups: groupParties(detail.parties),
    actions: detail.actions.map(toActionView),
    otherDocuments: detail.otherDocuments.map(toDocumentView),
  };
}
