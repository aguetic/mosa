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

  if (hasMultipleCharacterisations(event)) {
    notices.push("Multiple characterisations reported");
  } else {
    for (const statement of activeStatements(event.statements, "described_as")) {
      const value = provenanceStatementValue(statement);
      if (value.trim().length > 0) {
        notices.push(`Source describes the event as “${value}”`);
      }
    }
  }

  return dedupeNotices(notices);
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
