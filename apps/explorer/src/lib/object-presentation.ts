import type { ItemDocumentEntry, ItemSummary } from "./object-summary";
import { literalLabel } from "./presentation";
import type { ClaimDetail } from "./queries";

export interface ItemClaimRowView {
  claim: ClaimDetail;
  label: string;
  value: string;
  href: string | null;
  qualifications: string[];
}

export interface ItemSectionView {
  title: string;
  description: string;
  emptyText: string;
  rows: ItemClaimRowView[];
}

export interface ItemDocumentRowView {
  sourceId: string;
  sourceLabel: string;
  sourceHref: string;
  associations: string[];
  caseLinks: Array<{
    caseId: string;
    label: string;
    href: string;
  }>;
}

export interface ItemPageView {
  origin: ItemSectionView;
  currentState: ItemSectionView;
  documents: {
    title: string;
    description: string;
    emptyText: string;
    rows: ItemDocumentRowView[];
  };
  provenanceEmptyText: string;
  remainingOutgoingClaims: ClaimDetail[];
  remainingIncomingClaims: ClaimDetail[];
}

function claimValue(claim: ClaimDetail): string {
  return claim.valueKind === "entity"
    ? (claim.objectEntityLabel ?? claim.objectEntityId ?? "Not recorded")
    : literalLabel(claim);
}

function claimValueHref(claim: ClaimDetail): string | null {
  if (!claim.objectEntityId) {
    return null;
  }

  return claim.objectEntityType === "event"
    ? `/events/${claim.objectEntityId}`
    : `/entities/${claim.objectEntityId}`;
}

function sourceQualifications(claim: ClaimDetail): string[] {
  return claim.evidence
    .filter((evidence) => evidence.relationship === "qualifies" && evidence.excerpt)
    .map((evidence) => evidence.excerpt as string);
}

export function originClaimLabel(claim: ClaimDetail): string {
  return (
    {
      made_at: "Made at",
      made_during: "Production period",
      found_at: "Found or documented at",
    }[claim.predicate] ?? claim.predicate
  );
}

export function currentStateClaimLabel(
  claim: ClaimDetail,
  currentStateClaims: readonly ClaimDetail[],
): string {
  if (claim.predicate === "located_at") {
    if (claim.objectPlaceKind === "gallery") {
      return "Display location";
    }

    const hasDisplayLocation = currentStateClaims.some(
      (other) => other.predicate === "located_at" && other.objectPlaceKind === "gallery",
    );
    return hasDisplayLocation ? "Broader location" : "Location";
  }

  return (
    {
      held_by: "Held by",
    }[claim.predicate] ?? claim.predicate
  );
}

function toClaimRow(claim: ClaimDetail, label: string): ItemClaimRowView {
  return {
    claim,
    label,
    value: claimValue(claim),
    href: claimValueHref(claim),
    qualifications: sourceQualifications(claim),
  };
}

function toDocumentRow(document: ItemDocumentEntry): ItemDocumentRowView {
  const caseLinks = new Map<string, { caseId: string; label: string; href: string }>();
  for (const association of document.associations) {
    if (association.caseId && association.caseReference) {
      caseLinks.set(association.caseId, {
        caseId: association.caseId,
        label: association.caseReference,
        href: `/restitution/cases/${association.caseId}`,
      });
    }
  }

  return {
    sourceId: document.sourceId,
    sourceLabel: document.sourceLabel,
    sourceHref: `/entities/${document.sourceId}`,
    associations: document.associations.map((association) => association.label),
    caseLinks: [...caseLinks.values()],
  };
}

export function itemPageView(summary: ItemSummary): ItemPageView {
  return {
    origin: {
      title: "Origin",
      description:
        "Where and when the item was reportedly made, and any documented findspot before removal. Production place, findspot, and later movement origins remain distinct.",
      emptyText: "Origin is not recorded.",
      rows: summary.originClaims.map((claim) => toClaimRow(claim, originClaimLabel(claim))),
    },
    currentState: {
      title: "Current recorded state",
      description:
        "Current custody and location claims do not imply ownership, lawful title, or legitimate acquisition.",
      emptyText: "Current custodian and location are not recorded.",
      rows: summary.currentStateClaims.map((claim) =>
        toClaimRow(claim, currentStateClaimLabel(claim, summary.currentStateClaims)),
      ),
    },
    documents: {
      title: "Documents about this object",
      description:
        "Sources that refer to, depict, evidence, identify, or administratively document this object.",
      emptyText: "No documents about this object are recorded.",
      rows: summary.documents.map(toDocumentRow),
    },
    provenanceEmptyText: "No provenance events are recorded.",
    remainingOutgoingClaims: summary.remainingOutgoingClaims,
    remainingIncomingClaims: summary.remainingIncomingClaims,
  };
}
