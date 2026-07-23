import type { ProvenanceEvent, ProvenanceStatement } from "./provenance";

export interface ProvenanceDateLiteral {
  type?: string;
  earliest?: string;
  latest?: string;
  verbatim?: string;
  precision?: string;
  interpretation?: string;
  alternatives?: string[];
}

export interface ProvenanceDateSummary {
  label: string;
  sortStart: string | null;
  sortEnd: string | null;
  category: "dated" | "undated";
  notices: string[];
}

export interface ProvenanceEventSummary {
  eventId: string;
  dateLabel: string;
  sortStart: string | null;
  sortEnd: string | null;
  dateCategory: "dated" | "undated";
  title: string;
  /** Short narrative for sparse events; derived, not persisted. */
  summaryText: string | null;
  facts: Array<{
    label: string;
    value: string;
    href?: string;
  }>;
  notices: string[];
  sources: Array<{
    id: string;
    label: string;
  }>;
}

export interface ProvenanceEventDetailRow {
  label: string;
  value: string;
  href?: string;
  recorded: boolean;
}

export interface ProvenanceEventDetailSection {
  title: string;
  rows: ProvenanceEventDetailRow[];
}

export interface ProvenanceEventDetailView {
  sections: ProvenanceEventDetailSection[];
  /** One compact incompleteness notice when useful; derived, not persisted. */
  incompletenessNotice: string | null;
}

export const REPORTED_MOVEMENT_ACTION = "Physical movement";
export const ROUTE_AND_PARTICIPANTS_NOT_RECORDED = "Route and participants are not recorded.";

const SUMMARY_FACT_PREDICATES = [
  "moved_from",
  "moved_to",
  "moved_via",
  "occurred_at",
  "carried_out_by",
  "transferred_from",
  "transferred_to",
  "holding_agent",
] as const;

const FACT_LABELS: Record<(typeof SUMMARY_FACT_PREDICATES)[number], string> = {
  moved_from: "From",
  moved_to: "To",
  moved_via: "Via",
  occurred_at: "Event location",
  carried_out_by: "Carried out by",
  transferred_from: "Transferred from",
  transferred_to: "Transferred to",
  holding_agent: "Holder",
};

const TITLE_COVERED_PREDICATES: Record<string, readonly string[]> = {
  transfer: ["transferred_from", "transferred_to"],
  transferTo: ["transferred_to"],
  movement: ["moved_from", "moved_to"],
  arrival: ["moved_to"],
  holding: ["holding_agent"],
  placeActor: ["occurred_at", "carried_out_by"],
  place: ["occurred_at"],
};

function literalRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  return value as Record<string, unknown>;
}

function asDateLiteral(value: unknown): ProvenanceDateLiteral | null {
  const record = literalRecord(value);
  if (!record) {
    return null;
  }

  const alternatives = Array.isArray(record.alternatives)
    ? record.alternatives.filter((entry): entry is string => typeof entry === "string")
    : undefined;

  return {
    type: typeof record.type === "string" ? record.type : undefined,
    earliest: typeof record.earliest === "string" ? record.earliest : undefined,
    latest: typeof record.latest === "string" ? record.latest : undefined,
    verbatim: typeof record.verbatim === "string" ? record.verbatim : undefined,
    precision: typeof record.precision === "string" ? record.precision : undefined,
    interpretation: typeof record.interpretation === "string" ? record.interpretation : undefined,
    alternatives,
  };
}

function activeStatements(
  statements: readonly ProvenanceStatement[],
  predicate: string,
): ProvenanceStatement[] {
  return statements.filter(
    (statement) => statement.predicate === predicate && statement.status === "active",
  );
}

function entityLabel(statement: ProvenanceStatement | undefined): string | null {
  if (statement?.valueKind !== "entity") {
    return null;
  }

  return statement.objectEntityLabel ?? statement.objectEntityId;
}

function entityHref(statement: ProvenanceStatement): string | undefined {
  if (!statement.objectEntityId) {
    return undefined;
  }

  return statement.objectEntityType === "event"
    ? `/events/${statement.objectEntityId}`
    : `/entities/${statement.objectEntityId}`;
}

function dedupeNotices(notices: readonly string[]): string[] {
  return [...new Set(notices)];
}

export function provenanceStatementValue(statement: ProvenanceStatement): string {
  if (statement.valueKind === "entity") {
    return statement.objectEntityLabel ?? statement.objectEntityId ?? "Unrecorded entity";
  }

  const record = literalRecord(statement.literalValue);
  if (record) {
    if (typeof record.verbatim === "string") {
      return record.verbatim;
    }
    if (typeof record.value === "string") {
      return record.value;
    }
    if (Array.isArray(record.alternatives)) {
      const alternatives = record.alternatives.filter(
        (value): value is string => typeof value === "string",
      );
      if (alternatives.length > 0) {
        return alternatives.join(" or ");
      }
    }
    if (typeof record.earliest === "string" || typeof record.latest === "string") {
      return [record.earliest, record.latest].filter(Boolean).join("–");
    }
  }

  if (statement.literalDisplayValue) {
    return statement.literalDisplayValue;
  }

  return statement.literalValue === null
    ? "Unrecorded literal"
    : JSON.stringify(statement.literalValue);
}

export function summarizeProvenanceDate(
  statements: readonly ProvenanceStatement[],
): ProvenanceDateSummary {
  const dateClaims = activeStatements(statements, "occurred_during");
  if (dateClaims.length === 0) {
    return {
      label: "Date not recorded",
      sortStart: null,
      sortEnd: null,
      category: "undated",
      notices: ["Date not recorded"],
    };
  }

  const literals = dateClaims
    .map((claim) => asDateLiteral(claim.literalValue))
    .filter((literal): literal is ProvenanceDateLiteral => literal !== null);

  const primary = literals[0] ?? {};
  const notices: string[] = [];
  const hasAlternatives =
    primary.interpretation === "alternatives" ||
    (primary.alternatives !== undefined && primary.alternatives.length > 0) ||
    literals.some(
      (literal) =>
        literal.interpretation === "alternatives" ||
        (literal.alternatives !== undefined && literal.alternatives.length > 0),
    );

  if (hasAlternatives) {
    notices.push("Alternative dates reported");
  }

  if (
    primary.interpretation === "approximate" ||
    literals.some((literal) => literal.interpretation === "approximate")
  ) {
    notices.push("Approximate date");
  }

  const sortStarts = literals
    .map((literal) => literal.earliest ?? null)
    .filter((value): value is string => value !== null)
    .sort();
  const sortEnds = literals
    .map((literal) => literal.latest ?? literal.earliest ?? null)
    .filter((value): value is string => value !== null)
    .sort();

  const rangeLabel = [primary.earliest, primary.latest].filter(Boolean).join("–");
  const label =
    primary.verbatim ??
    (hasAlternatives && primary.alternatives && primary.alternatives.length > 0
      ? primary.alternatives.join(" or ")
      : null) ??
    (rangeLabel.length > 0 ? rangeLabel : null) ??
    "Date not recorded";

  return {
    label,
    sortStart: sortStarts[0] ?? null,
    sortEnd: sortEnds[sortEnds.length - 1] ?? null,
    category: "dated",
    notices: dedupeNotices(notices),
  };
}

export function generateProvenanceEventTitle(event: ProvenanceEvent): string {
  const transferredFrom = entityLabel(activeStatements(event.statements, "transferred_from")[0]);
  const transferredTo = entityLabel(activeStatements(event.statements, "transferred_to")[0]);
  if (transferredFrom && transferredTo) {
    return `Transfer from ${transferredFrom} to ${transferredTo}`;
  }

  if (transferredTo) {
    return `Transfer to ${transferredTo}`;
  }

  const movedFrom = entityLabel(activeStatements(event.statements, "moved_from")[0]);
  const movedTo = entityLabel(activeStatements(event.statements, "moved_to")[0]);
  if (movedFrom && movedTo) {
    return `Movement from ${movedFrom} to ${movedTo}`;
  }

  if (movedTo && !movedFrom) {
    return `Arrival in ${movedTo}`;
  }

  const holdingAgent = entityLabel(activeStatements(event.statements, "holding_agent")[0]);
  if (holdingAgent) {
    return `Held by ${holdingAgent}`;
  }

  const occurredAt = entityLabel(activeStatements(event.statements, "occurred_at")[0]);
  const carriedOutBy = entityLabel(activeStatements(event.statements, "carried_out_by")[0]);
  if (occurredAt && carriedOutBy) {
    return `Event at ${occurredAt} involving ${carriedOutBy}`;
  }

  if (occurredAt) {
    return `Event at ${occurredAt}`;
  }

  const movedItem = entityLabel(activeStatements(event.statements, "moved_item")[0]);
  if (movedItem && !movedFrom && !movedTo) {
    return `Reported movement of ${movedItem}`;
  }

  if (movedItem) {
    return "Reported movement";
  }

  if (activeStatements(event.statements, "transferred_item").length > 0) {
    return "Transfer event";
  }

  return "Provenance event";
}

function titleCoveredPredicates(event: ProvenanceEvent): Set<string> {
  const transferredFrom = entityLabel(activeStatements(event.statements, "transferred_from")[0]);
  const transferredTo = entityLabel(activeStatements(event.statements, "transferred_to")[0]);
  if (transferredFrom && transferredTo) {
    return new Set(TITLE_COVERED_PREDICATES.transfer);
  }

  if (transferredTo) {
    return new Set(TITLE_COVERED_PREDICATES.transferTo);
  }

  const movedFrom = entityLabel(activeStatements(event.statements, "moved_from")[0]);
  const movedTo = entityLabel(activeStatements(event.statements, "moved_to")[0]);
  if (movedFrom && movedTo) {
    return new Set(TITLE_COVERED_PREDICATES.movement);
  }

  if (movedTo && !movedFrom) {
    return new Set(TITLE_COVERED_PREDICATES.arrival);
  }

  if (entityLabel(activeStatements(event.statements, "holding_agent")[0])) {
    return new Set(TITLE_COVERED_PREDICATES.holding);
  }

  const occurredAt = entityLabel(activeStatements(event.statements, "occurred_at")[0]);
  const carriedOutBy = entityLabel(activeStatements(event.statements, "carried_out_by")[0]);
  if (occurredAt && carriedOutBy) {
    return new Set(TITLE_COVERED_PREDICATES.placeActor);
  }

  if (occurredAt) {
    return new Set(TITLE_COVERED_PREDICATES.place);
  }

  return new Set();
}

function compactFacts(event: ProvenanceEvent): ProvenanceEventSummary["facts"] {
  const covered = titleCoveredPredicates(event);
  const facts: ProvenanceEventSummary["facts"] = [];

  for (const predicate of SUMMARY_FACT_PREDICATES) {
    if (covered.has(predicate)) {
      continue;
    }

    for (const statement of activeStatements(event.statements, predicate)) {
      const value = provenanceStatementValue(statement);
      facts.push({
        label: FACT_LABELS[predicate],
        value,
        href: statement.valueKind === "entity" ? entityHref(statement) : undefined,
      });
    }
  }

  return facts;
}

function hasMultipleCharacterisations(event: ProvenanceEvent): boolean {
  const descriptions = new Set(
    activeStatements(event.statements, "described_as")
      .map(provenanceStatementValue)
      .map((value) => value.trim().toLocaleLowerCase("en"))
      .filter(Boolean),
  );

  return descriptions.size >= 2;
}

function hasActivePredicate(event: ProvenanceEvent, predicate: string): boolean {
  return activeStatements(event.statements, predicate).length > 0;
}

function isSparseMovement(event: ProvenanceEvent): boolean {
  return (
    hasActivePredicate(event, "moved_item") &&
    !hasActivePredicate(event, "moved_from") &&
    !hasActivePredicate(event, "moved_to")
  );
}

function primaryMovedItemEvidence(event: ProvenanceEvent) {
  const movedItem = activeStatements(event.statements, "moved_item")[0];
  return movedItem?.evidence[0] ?? null;
}

/** Compact incompleteness notice for sparse movements. Derived, not persisted. */
export function movementIncompletenessNotice(event: ProvenanceEvent): string | null {
  if (!isSparseMovement(event)) {
    return null;
  }

  if (hasActivePredicate(event, "carried_out_by")) {
    return "Route is not recorded.";
  }

  return ROUTE_AND_PARTICIPANTS_NOT_RECORDED;
}

/** Narrative for a movement with no recorded endpoints. Gaps belong in notices. */
export function sparseMovementSummaryText(event: ProvenanceEvent): string | null {
  if (!isSparseMovement(event)) {
    return null;
  }

  const evidence = primaryMovedItemEvidence(event);
  const sourceLabel = evidence?.sourceLabel?.trim() || null;
  const excerpt = evidence?.excerpt?.trim() || null;

  if (sourceLabel && excerpt) {
    return `${sourceLabel} reports that the item “${excerpt}”.`;
  }

  if (sourceLabel) {
    return `${sourceLabel} reports that the item was moved.`;
  }

  return "A source reports that the item was moved.";
}

function sourceWordingNotice(event: ProvenanceEvent): string | null {
  if (hasMultipleCharacterisations(event)) {
    return "Multiple characterisations reported";
  }

  const description = activeStatements(event.statements, "described_as")[0];
  if (!description) {
    return null;
  }

  const value = provenanceStatementValue(description).trim();
  if (!value) {
    return null;
  }

  return `Source wording: “${value}”`;
}

function eventNotices(event: ProvenanceEvent, dateSummary: ProvenanceDateSummary): string[] {
  const notices = [...dateSummary.notices];

  const hasQualifies = event.statements.some((statement) =>
    statement.evidence.some((evidence) => evidence.relationship === "qualifies"),
  );
  if (hasQualifies) {
    notices.push("Source includes a qualification");
  }

  const hasContradicts = event.statements.some((statement) =>
    statement.evidence.some((evidence) => evidence.relationship === "contradicts"),
  );
  if (hasContradicts) {
    notices.push("Conflicting evidence");
  }

  const wording = sourceWordingNotice(event);
  if (wording) {
    notices.push(wording);
  }

  const incompleteness = movementIncompletenessNotice(event);
  if (incompleteness) {
    notices.push(incompleteness);
  }

  return dedupeNotices(notices);
}

function recordedEntityDetail(
  event: ProvenanceEvent,
  predicate: string,
  label: string,
): ProvenanceEventDetailRow | null {
  const statement = activeStatements(event.statements, predicate)[0];
  if (!statement) {
    return null;
  }

  return {
    label,
    value: provenanceStatementValue(statement),
    href: statement.valueKind === "entity" ? entityHref(statement) : undefined,
    recorded: true,
  };
}

function recordedItemDetail(event: ProvenanceEvent): ProvenanceEventDetailRow | null {
  for (const predicate of ["moved_item", "transferred_item", "held_item"] as const) {
    const detail = recordedEntityDetail(event, predicate, "Item");
    if (detail) {
      return detail;
    }
  }

  return null;
}

function recordedTransferPartiesDetail(event: ProvenanceEvent): ProvenanceEventDetailRow | null {
  const from = activeStatements(event.statements, "transferred_from")[0];
  const to = activeStatements(event.statements, "transferred_to")[0];

  if (!from && !to) {
    return null;
  }

  if (from && to) {
    return {
      label: "Transfer parties",
      value: `${provenanceStatementValue(from)} → ${provenanceStatementValue(to)}`,
      recorded: true,
    };
  }

  const sole = from ?? to;
  if (!sole) {
    return null;
  }

  return {
    label: "Transfer parties",
    value: provenanceStatementValue(sole),
    href: sole.valueKind === "entity" ? entityHref(sole) : undefined,
    recorded: true,
  };
}

function characterisationRows(statement: ProvenanceStatement): ProvenanceEventDetailRow[] {
  const rows: ProvenanceEventDetailRow[] = [];
  const value = provenanceStatementValue(statement).trim();
  const evidence = statement.evidence[0];
  const speaker =
    statement.assertedByLabel ?? (statement.assertedByAgentId ? statement.assertedByAgentId : null);

  if (value.length > 0) {
    rows.push({
      label: "Reported characterisation",
      value: `“${value}”`,
      recorded: true,
    });
  }

  if (speaker) {
    rows.push({
      label: "Underlying speaker",
      value: speaker,
      href: statement.assertedByAgentId ? `/entities/${statement.assertedByAgentId}` : undefined,
      recorded: true,
    });
  }

  if (evidence?.sourceLabel) {
    const relationshipLabel =
      evidence.relationship === "mentions"
        ? `Indirect report in ${evidence.sourceLabel}`
        : evidence.relationship === "supports"
          ? `Direct support in ${evidence.sourceLabel}`
          : `${evidence.relationship} in ${evidence.sourceLabel}`;

    rows.push({
      label: "Evidence type",
      value: relationshipLabel,
      href: `/entities/${evidence.sourceId}`,
      recorded: true,
    });
  }

  return rows;
}

/**
 * Event-detail projection of positively recorded facts.
 * Absent roles are omitted; incompleteness is a single optional notice.
 */
export function provenanceEventDetailView(event: ProvenanceEvent): ProvenanceEventDetailView {
  const dateSummary = summarizeProvenanceDate(event.statements);
  const hasMovedItem = hasActivePredicate(event, "moved_item");
  const hasTransferItem = hasActivePredicate(event, "transferred_item");

  const recordedRows: ProvenanceEventDetailRow[] = [];

  if (hasMovedItem) {
    recordedRows.push({
      label: "Reported action",
      value: REPORTED_MOVEMENT_ACTION,
      recorded: true,
    });
  }

  const item = recordedItemDetail(event);
  if (item) {
    recordedRows.push(item);
  }

  if (dateSummary.category === "dated") {
    recordedRows.push({
      label: "Date",
      value: dateSummary.label,
      recorded: true,
    });
  }

  for (const row of [
    recordedEntityDetail(event, "moved_from", "Origin"),
    recordedEntityDetail(event, "moved_to", "Destination"),
    recordedEntityDetail(event, "carried_out_by", "Person or group carrying it out"),
  ]) {
    if (row) {
      recordedRows.push(row);
    }
  }

  // Show transfer parties only when a transfer is positively recorded.
  if (
    hasTransferItem ||
    hasActivePredicate(event, "transferred_from") ||
    hasActivePredicate(event, "transferred_to")
  ) {
    const parties = recordedTransferPartiesDetail(event);
    if (parties) {
      recordedRows.push(parties);
    }
  }

  const sections: ProvenanceEventDetailSection[] = [];
  if (recordedRows.length > 0) {
    sections.push({ title: "Recorded details", rows: recordedRows });
  }

  for (const statement of activeStatements(event.statements, "described_as")) {
    const rows = characterisationRows(statement);
    if (rows.length > 0) {
      sections.push({ title: "Source characterisation", rows });
    }
  }

  return {
    sections,
    incompletenessNotice: movementIncompletenessNotice(event),
  };
}

function eventSources(event: ProvenanceEvent): ProvenanceEventSummary["sources"] {
  const byId = new Map<string, string>();

  for (const statement of event.statements) {
    for (const evidence of statement.evidence) {
      if (!byId.has(evidence.sourceId)) {
        byId.set(evidence.sourceId, evidence.sourceLabel);
      }
    }
  }

  return [...byId.entries()]
    .map(([id, label]) => ({ id, label }))
    .sort(
      (left, right) => left.label.localeCompare(right.label) || left.id.localeCompare(right.id),
    );
}

export function summarizeProvenanceEvent(event: ProvenanceEvent): ProvenanceEventSummary {
  const dateSummary = summarizeProvenanceDate(event.statements);

  return {
    eventId: event.id,
    dateLabel: dateSummary.label,
    sortStart: dateSummary.sortStart,
    sortEnd: dateSummary.sortEnd,
    dateCategory: dateSummary.category,
    title: generateProvenanceEventTitle(event),
    summaryText: sparseMovementSummaryText(event),
    facts: compactFacts(event),
    notices: eventNotices(event, dateSummary),
    sources: eventSources(event),
  };
}

export function orderProvenanceEvents(events: readonly ProvenanceEvent[]): ProvenanceEvent[] {
  return [...events].sort((left, right) => {
    const leftDate = summarizeProvenanceDate(left.statements);
    const rightDate = summarizeProvenanceDate(right.statements);

    if (leftDate.category !== rightDate.category) {
      return leftDate.category === "dated" ? -1 : 1;
    }

    if (leftDate.sortStart !== rightDate.sortStart) {
      if (leftDate.sortStart === null) {
        return 1;
      }
      if (rightDate.sortStart === null) {
        return -1;
      }
      return leftDate.sortStart.localeCompare(rightDate.sortStart);
    }

    if (leftDate.sortEnd !== rightDate.sortEnd) {
      if (leftDate.sortEnd === null) {
        return 1;
      }
      if (rightDate.sortEnd === null) {
        return -1;
      }
      return leftDate.sortEnd.localeCompare(rightDate.sortEnd);
    }

    return left.id.localeCompare(right.id);
  });
}
