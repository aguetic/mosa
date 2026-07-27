import type { ProvenanceEvent } from "./provenance";
import type { ClaimDetail } from "./queries";
import type { RestitutionCaseSummary, RestitutionItemDocument } from "./restitution";
import type { ExternalIdentifier } from "./values";

export const EVENT_LINK_PREDICATES = new Set(["moved_item", "held_item", "transferred_item"]);

export const ORIGIN_PREDICATES = ["made_at", "made_during", "found_at"] as const;
export const CURRENT_STATE_PREDICATES = ["held_by", "located_at"] as const;
export const DOCUMENT_LINK_PREDICATES = new Set(["refers_to", "depicts"]);

const ORIGIN_PREDICATE_SET = new Set<string>(ORIGIN_PREDICATES);
const CURRENT_STATE_PREDICATE_SET = new Set<string>(CURRENT_STATE_PREDICATES);
const ITEM_SUMMARY_PREDICATES = new Set<string>([
  ...ORIGIN_PREDICATES,
  ...CURRENT_STATE_PREDICATES,
]);

export type ItemDocumentKind =
  | "refers_to"
  | "depicts"
  | "evidence"
  | "identifier_source"
  | "restitution";

export interface ItemDocumentAssociation {
  kind: ItemDocumentKind;
  label: string;
  claimId: string | null;
  caseId: string | null;
  caseReference: string | null;
}

export interface ItemDocumentEntry {
  sourceId: string;
  sourceLabel: string;
  associations: ItemDocumentAssociation[];
}

export interface ItemSummary {
  originClaims: ClaimDetail[];
  currentStateClaims: ClaimDetail[];
  documents: ItemDocumentEntry[];
  provenanceEvents: ProvenanceEvent[];
  restitutionCases: RestitutionCaseSummary[];
  remainingOutgoingClaims: ClaimDetail[];
  remainingIncomingClaims: ClaimDetail[];
}

export interface BuildItemSummaryInput {
  itemId: string;
  claims: readonly ClaimDetail[];
  identifiers?: readonly ExternalIdentifier[];
  provenanceEvents: readonly ProvenanceEvent[];
  restitutionCases: readonly RestitutionCaseSummary[];
  restitutionDocuments: readonly RestitutionItemDocument[];
}

function activeOutgoing(claims: readonly ClaimDetail[], itemId: string): ClaimDetail[] {
  return claims.filter((claim) => claim.subjectId === itemId && claim.status === "active");
}

function sortByPredicateOrder(
  claims: readonly ClaimDetail[],
  order: readonly string[],
): ClaimDetail[] {
  const rank = new Map(order.map((predicate, index) => [predicate, index]));
  return [...claims].sort((left, right) => {
    const leftRank = rank.get(left.predicate) ?? Number.MAX_SAFE_INTEGER;
    const rightRank = rank.get(right.predicate) ?? Number.MAX_SAFE_INTEGER;
    if (leftRank !== rightRank) {
      return leftRank - rightRank;
    }
    return left.id.localeCompare(right.id);
  });
}

function humanizeToken(value: string): string {
  return value
    .split("_")
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function evidenceAssociationLabel(relationship: string): string {
  if (relationship === "qualifies") {
    return "Qualifies a claim";
  }
  if (relationship === "supports") {
    return "Supports a claim";
  }
  if (relationship === "mentions") {
    return "Mentions a claim";
  }
  if (relationship === "contradicts") {
    return "Contradicts a claim";
  }
  if (relationship === "provides_context") {
    return "Provides context for a claim";
  }
  return humanizeToken(relationship);
}

function ensureDocument(
  documents: Map<string, ItemDocumentEntry>,
  sourceId: string,
  sourceLabel: string,
): ItemDocumentEntry {
  const existing = documents.get(sourceId);
  if (existing) {
    if (!existing.sourceLabel && sourceLabel) {
      existing.sourceLabel = sourceLabel;
    }
    return existing;
  }

  const entry: ItemDocumentEntry = {
    sourceId,
    sourceLabel: sourceLabel || sourceId,
    associations: [],
  };
  documents.set(sourceId, entry);
  return entry;
}

function addAssociation(entry: ItemDocumentEntry, association: ItemDocumentAssociation): void {
  const duplicate = entry.associations.some(
    (existing) =>
      existing.kind === association.kind &&
      existing.label === association.label &&
      existing.claimId === association.claimId &&
      existing.caseId === association.caseId,
  );
  if (!duplicate) {
    entry.associations.push(association);
  }
}

function collectDocuments(input: BuildItemSummaryInput): ItemDocumentEntry[] {
  const documents = new Map<string, ItemDocumentEntry>();

  for (const claim of input.claims) {
    if (
      claim.objectEntityId === input.itemId &&
      DOCUMENT_LINK_PREDICATES.has(claim.predicate) &&
      claim.status === "active"
    ) {
      const entry = ensureDocument(documents, claim.subjectId, claim.subjectLabel);
      addAssociation(entry, {
        kind: claim.predicate === "depicts" ? "depicts" : "refers_to",
        label: claim.predicate === "depicts" ? "Depicts this object" : "Refers to this object",
        claimId: claim.id,
        caseId: null,
        caseReference: null,
      });
    }

    for (const evidence of claim.evidence) {
      const entry = ensureDocument(documents, evidence.sourceId, evidence.sourceLabel);
      addAssociation(entry, {
        kind: "evidence",
        label: evidenceAssociationLabel(evidence.relationship),
        claimId: claim.id,
        caseId: null,
        caseReference: null,
      });
    }
  }

  for (const identifier of input.identifiers ?? []) {
    if (!identifier.sourceId) {
      continue;
    }
    const entry = ensureDocument(
      documents,
      identifier.sourceId,
      identifier.sourceLabel ?? identifier.sourceId,
    );
    addAssociation(entry, {
      kind: "identifier_source",
      label: `Establishes identifier ${identifier.namespace}:${identifier.value}`,
      claimId: null,
      caseId: null,
      caseReference: null,
    });
  }

  for (const document of input.restitutionDocuments) {
    const entry = ensureDocument(documents, document.sourceId, document.sourceLabel);
    addAssociation(entry, {
      kind: "restitution",
      label: `${humanizeToken(document.documentRole)} · case ${document.caseReference}`,
      claimId: null,
      caseId: document.caseId,
      caseReference: document.caseReference,
    });
  }

  return [...documents.values()].sort((left, right) => {
    const labelCompare = left.sourceLabel.localeCompare(right.sourceLabel);
    if (labelCompare !== 0) {
      return labelCompare;
    }
    return left.sourceId.localeCompare(right.sourceId);
  });
}

export function buildItemSummary(input: BuildItemSummaryInput): ItemSummary {
  const outgoing = input.claims.filter((claim) => claim.subjectId === input.itemId);
  const incoming = input.claims.filter(
    (claim) => claim.objectEntityId === input.itemId && !EVENT_LINK_PREDICATES.has(claim.predicate),
  );
  const active = activeOutgoing(input.claims, input.itemId);

  return {
    originClaims: sortByPredicateOrder(
      active.filter((claim) => ORIGIN_PREDICATE_SET.has(claim.predicate)),
      ORIGIN_PREDICATES,
    ),
    currentStateClaims: sortByPredicateOrder(
      active.filter((claim) => CURRENT_STATE_PREDICATE_SET.has(claim.predicate)),
      CURRENT_STATE_PREDICATES,
    ),
    documents: collectDocuments(input),
    provenanceEvents: [...input.provenanceEvents],
    restitutionCases: [...input.restitutionCases],
    remainingOutgoingClaims: outgoing.filter(
      (claim) => !ITEM_SUMMARY_PREDICATES.has(claim.predicate),
    ),
    remainingIncomingClaims: incoming.filter(
      (claim) => !DOCUMENT_LINK_PREDICATES.has(claim.predicate),
    ),
  };
}
