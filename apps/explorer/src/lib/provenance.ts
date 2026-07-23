import type { QueryResultRow } from "pg";
import { query } from "./database";
import { orderProvenanceEvents } from "./provenance-presentation";

export interface ProvenanceEvidence {
  id: string;
  sourceId: string;
  sourceLabel: string;
  relationship: string;
  locator: string | null;
  excerpt: string | null;
  notes: string | null;
}

export interface ProvenanceStatement {
  id: string;
  subjectId: string;
  subjectLabel: string;
  predicate: string;
  valueKind: "entity" | "literal";
  objectEntityId: string | null;
  objectEntityLabel: string | null;
  objectEntityType: string | null;
  literalValue: unknown;
  literalDisplayValue: string | null;
  literalLanguage: string | null;
  assertedByAgentId: string | null;
  assertedByLabel: string | null;
  status: string;
  notes: string | null;
  evidence: ProvenanceEvidence[];
}

export interface ProvenanceEvent {
  id: string;
  eventKind: string;
  notes: string | null;
  statements: ProvenanceStatement[];
}

export interface ProvenanceEventDetail extends ProvenanceEvent {
  incomingStatements: ProvenanceStatement[];
}

interface EventRow extends QueryResultRow {
  id: string;
  event_kind: string;
  notes: string | null;
}

interface StatementRow extends QueryResultRow {
  claim_id: string;
  subject_id: string;
  subject_label: string;
  predicate: string;
  value_kind: "entity" | "literal";
  object_entity_id: string | null;
  object_entity_label: string | null;
  object_entity_type: string | null;
  literal_value: unknown;
  literal_display_value: string | null;
  literal_language: string | null;
  asserted_by_agent_id: string | null;
  asserted_by_label: string | null;
  status: string;
  notes: string | null;
}

interface EvidenceRow extends QueryResultRow {
  claim_evidence_id: string;
  claim_id: string;
  source_id: string;
  source_label: string;
  relationship: string;
  locator: string | null;
  excerpt: string | null;
  evidence_notes: string | null;
}

const STATEMENT_SELECT = `
  select
      claim_id::text,
      subject_id::text,
      subject_label,
      predicate,
      value_kind,
      object_entity_id::text,
      object_entity_label,
      object_entity_type,
      literal_value,
      literal_display_value,
      literal_language,
      asserted_by_agent_id::text,
      asserted_by_label,
      status,
      notes
  from knowledge.claim_details
`;

function toEvidence(row: EvidenceRow): ProvenanceEvidence {
  return {
    id: row.claim_evidence_id,
    sourceId: row.source_id,
    sourceLabel: row.source_label,
    relationship: row.relationship,
    locator: row.locator,
    excerpt: row.excerpt,
    notes: row.evidence_notes,
  };
}

async function evidenceForClaims(
  claimIds: readonly string[],
): Promise<Map<string, ProvenanceEvidence[]>> {
  if (claimIds.length === 0) {
    return new Map();
  }

  const rows = await query<EvidenceRow>(
    `select
         claim_evidence_id::text,
         claim_id::text,
         source_id::text,
         source_label,
         relationship,
         locator,
         excerpt,
         evidence_notes
     from knowledge.claim_evidence_details
     where claim_id = any($1::uuid[])
     order by claim_id, evidence_created_at, claim_evidence_id`,
    [claimIds],
  );

  const byClaim = new Map<string, ProvenanceEvidence[]>();
  for (const row of rows) {
    const evidence = byClaim.get(row.claim_id) ?? [];
    evidence.push(toEvidence(row));
    byClaim.set(row.claim_id, evidence);
  }

  return byClaim;
}

async function loadStatements(
  whereClause: string,
  values: readonly unknown[],
): Promise<ProvenanceStatement[]> {
  const rows = await query<StatementRow>(
    `${STATEMENT_SELECT}
     where ${whereClause}
     order by subject_label, predicate, claim_id`,
    values,
  );
  const evidenceByClaim = await evidenceForClaims(rows.map((row) => row.claim_id));

  return rows.map((row) => ({
    id: row.claim_id,
    subjectId: row.subject_id,
    subjectLabel: row.subject_label,
    predicate: row.predicate,
    valueKind: row.value_kind,
    objectEntityId: row.object_entity_id,
    objectEntityLabel: row.object_entity_label,
    objectEntityType: row.object_entity_type,
    literalValue: row.literal_value,
    literalDisplayValue: row.literal_display_value,
    literalLanguage: row.literal_language,
    assertedByAgentId: row.asserted_by_agent_id,
    assertedByLabel: row.asserted_by_label,
    status: row.status,
    notes: row.notes,
    evidence: evidenceByClaim.get(row.claim_id) ?? [],
  }));
}

export async function getProvenanceEventsForItem(itemId: string): Promise<ProvenanceEvent[]> {
  const rows = await query<EventRow>(
    `select
         event.id::text,
         event.event_kind,
         entity.notes
     from provenance.event as event
     join entities.entity as entity on entity.id = event.id
     where exists (
       select 1
       from knowledge.claim as item_claim
       where item_claim.subject_id = event.id
         and item_claim.predicate in ('moved_item', 'held_item')
         and item_claim.object_entity_id = $1::uuid
         and item_claim.status = 'active'
     )
     order by event.id`,
    [itemId],
  );

  if (rows.length === 0) {
    return [];
  }

  const eventIds = rows.map((row) => row.id);
  const statements = await loadStatements("subject_id = any($1::uuid[])", [eventIds]);
  const statementsByEvent = new Map<string, ProvenanceStatement[]>();
  for (const statement of statements) {
    const eventStatements = statementsByEvent.get(statement.subjectId) ?? [];
    eventStatements.push(statement);
    statementsByEvent.set(statement.subjectId, eventStatements);
  }

  return orderProvenanceEvents(
    rows.map((row) => ({
      id: row.id,
      eventKind: row.event_kind,
      notes: row.notes,
      statements: statementsByEvent.get(row.id) ?? [],
    })),
  );
}

export async function getProvenanceEvent(id: string): Promise<ProvenanceEventDetail | null> {
  const rows = await query<EventRow>(
    `select
         event.id::text,
         event.event_kind,
         entity.notes
     from provenance.event as event
     join entities.entity as entity on entity.id = event.id
     where event.id = $1::uuid`,
    [id],
  );
  const row = rows[0];
  if (!row) {
    return null;
  }

  const [statements, incomingStatements] = await Promise.all([
    loadStatements("subject_id = $1::uuid", [id]),
    loadStatements("object_entity_id = $1::uuid and subject_id <> $1::uuid", [id]),
  ]);

  return {
    id: row.id,
    eventKind: row.event_kind,
    notes: row.notes,
    statements,
    incomingStatements,
  };
}
