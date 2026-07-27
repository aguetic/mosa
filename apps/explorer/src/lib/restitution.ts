import type { QueryResultRow } from "pg";
import { query } from "./database";

export interface RestitutionDate {
  start: string | null;
  end: string | null;
  precision: string | null;
}

export interface RestitutionCaseSummary {
  id: string;
  reference: string;
  title: string;
  status: string;
}

export interface RestitutionCaseItem {
  itemId: string;
  itemLabel: string;
}

export interface RestitutionCaseParty {
  id: string;
  agentId: string;
  agentLabel: string;
  role: string;
}

export interface RestitutionActionParty {
  id: string;
  agentId: string;
  agentLabel: string;
  role: string;
}

export interface RestitutionLinkedDocument {
  id: string;
  sourceId: string;
  sourceLabel: string;
  documentRole: string;
  relationship: string | null;
}

export interface RestitutionCaseAction {
  id: string;
  sequenceNumber: number;
  actionKind: string;
  description: string;
  occurred: RestitutionDate;
  parties: RestitutionActionParty[];
  documents: RestitutionLinkedDocument[];
}

export interface RestitutionCaseDocument {
  id: string;
  sourceId: string;
  sourceLabel: string;
  documentRole: string;
}

export interface RestitutionCaseDetail {
  id: string;
  reference: string;
  title: string;
  status: string;
  opened: RestitutionDate;
  closed: RestitutionDate;
  items: RestitutionCaseItem[];
  parties: RestitutionCaseParty[];
  actions: RestitutionCaseAction[];
  otherDocuments: RestitutionCaseDocument[];
}

interface CaseSummaryRow extends QueryResultRow {
  id: string;
  reference: string;
  title: string;
  status: string;
}

interface CaseRow extends QueryResultRow {
  id: string;
  reference: string;
  title: string;
  status: string;
  opened_start: string | null;
  opened_end: string | null;
  opened_precision: string | null;
  closed_start: string | null;
  closed_end: string | null;
  closed_precision: string | null;
}

interface CaseItemRow extends QueryResultRow {
  item_id: string;
  item_label: string;
}

interface CasePartyRow extends QueryResultRow {
  id: string;
  agent_id: string;
  agent_label: string;
  role: string;
}

interface CaseActionRow extends QueryResultRow {
  id: string;
  sequence_number: number;
  action_kind: string;
  description: string;
  occurred_start: string | null;
  occurred_end: string | null;
  occurred_precision: string | null;
}

interface ActionPartyRow extends QueryResultRow {
  id: string;
  action_id: string;
  agent_id: string;
  agent_label: string;
  role: string;
}

interface CaseDocumentRow extends QueryResultRow {
  id: string;
  source_id: string;
  source_label: string;
  document_role: string;
}

interface ActionDocumentRow extends QueryResultRow {
  action_id: string;
  document_id: string;
  source_id: string;
  source_label: string;
  document_role: string;
  relationship: string | null;
}

function toDateOnly(value: string | Date | null): string | null {
  if (value == null) {
    return null;
  }

  if (value instanceof Date) {
    return value.toISOString().slice(0, 10);
  }

  return String(value).slice(0, 10);
}

function toRestitutionDate(
  start: string | Date | null,
  end: string | Date | null,
  precision: string | null,
): RestitutionDate {
  return {
    start: toDateOnly(start),
    end: toDateOnly(end),
    precision,
  };
}

function toCaseSummary(row: CaseSummaryRow): RestitutionCaseSummary {
  return {
    id: row.id,
    reference: row.reference,
    title: row.title,
    status: row.status,
  };
}

export async function getRestitutionCasesForItem(
  itemId: string,
): Promise<RestitutionCaseSummary[]> {
  const rows = await query<CaseSummaryRow>(
    `select
         case_record.id::text,
         case_record.reference,
         case_record.title,
         case_record.status
     from restitution.case_record as case_record
     join restitution.case_item as case_item
       on case_item.case_id = case_record.id
     where case_item.item_id = $1::uuid
     order by
         case_record.opened_start nulls last,
         case_record.reference,
         case_record.id`,
    [itemId],
  );

  return rows.map(toCaseSummary);
}

export async function getRestitutionCase(caseId: string): Promise<RestitutionCaseDetail | null> {
  const cases = await query<CaseRow>(
    `select
         case_record.id::text,
         case_record.reference,
         case_record.title,
         case_record.status,
         case_record.opened_start::text,
         case_record.opened_end::text,
         case_record.opened_precision,
         case_record.closed_start::text,
         case_record.closed_end::text,
         case_record.closed_precision
     from restitution.case_record as case_record
     where case_record.id = $1::uuid`,
    [caseId],
  );

  const caseRecord = cases[0];
  if (!caseRecord) {
    return null;
  }

  const [items, parties, actions, actionParties, documents, actionDocuments] = await Promise.all([
    query<CaseItemRow>(
      `select
           case_item.item_id::text,
           display.display_label as item_label
       from restitution.case_item as case_item
       join entities.entity_display as display
         on display.id = case_item.item_id
       where case_item.case_id = $1::uuid
       order by display.display_label, case_item.item_id`,
      [caseId],
    ),
    query<CasePartyRow>(
      `select
           party.id::text,
           party.agent_id::text,
           display.display_label as agent_label,
           party.role
       from restitution.case_party as party
       join entities.entity_display as display
         on display.id = party.agent_id
       where party.case_id = $1::uuid
       order by party.role, display.display_label, party.id`,
      [caseId],
    ),
    query<CaseActionRow>(
      `select
           action.id::text,
           action.sequence_number,
           action.action_kind,
           action.description,
           action.occurred_start::text,
           action.occurred_end::text,
           action.occurred_precision
       from restitution.case_action as action
       where action.case_id = $1::uuid
       order by action.sequence_number, action.id`,
      [caseId],
    ),
    query<ActionPartyRow>(
      `select
           action_party.id::text,
           action_party.action_id::text,
           action_party.agent_id::text,
           display.display_label as agent_label,
           action_party.role
       from restitution.action_party as action_party
       join restitution.case_action as action
         on action.id = action_party.action_id
       join entities.entity_display as display
         on display.id = action_party.agent_id
       where action.case_id = $1::uuid
       order by action.sequence_number, action_party.role, display.display_label, action_party.id`,
      [caseId],
    ),
    query<CaseDocumentRow>(
      `select
           document.id::text,
           document.source_id::text,
           display.display_label as source_label,
           document.document_role
       from restitution.case_document as document
       join entities.entity_display as display
         on display.id = document.source_id
       where document.case_id = $1::uuid
       order by document.document_role, display.display_label, document.id`,
      [caseId],
    ),
    query<ActionDocumentRow>(
      `select
           action_document.action_id::text,
           action_document.document_id::text,
           document.source_id::text,
           display.display_label as source_label,
           document.document_role,
           action_document.relationship
       from restitution.action_document as action_document
       join restitution.case_document as document
         on document.id = action_document.document_id
       join entities.entity_display as display
         on display.id = document.source_id
       where action_document.case_id = $1::uuid
       order by
           document.document_role,
           display.display_label,
           action_document.document_id`,
      [caseId],
    ),
  ]);

  const partiesByAction = new Map<string, RestitutionActionParty[]>();
  for (const row of actionParties) {
    const list = partiesByAction.get(row.action_id) ?? [];
    list.push({
      id: row.id,
      agentId: row.agent_id,
      agentLabel: row.agent_label,
      role: row.role,
    });
    partiesByAction.set(row.action_id, list);
  }

  const documentsByAction = new Map<string, RestitutionLinkedDocument[]>();
  const linkedDocumentIds = new Set<string>();
  for (const row of actionDocuments) {
    linkedDocumentIds.add(row.document_id);
    const list = documentsByAction.get(row.action_id) ?? [];
    list.push({
      id: row.document_id,
      sourceId: row.source_id,
      sourceLabel: row.source_label,
      documentRole: row.document_role,
      relationship: row.relationship,
    });
    documentsByAction.set(row.action_id, list);
  }

  return {
    id: caseRecord.id,
    reference: caseRecord.reference,
    title: caseRecord.title,
    status: caseRecord.status,
    opened: toRestitutionDate(
      caseRecord.opened_start,
      caseRecord.opened_end,
      caseRecord.opened_precision,
    ),
    closed: toRestitutionDate(
      caseRecord.closed_start,
      caseRecord.closed_end,
      caseRecord.closed_precision,
    ),
    items: items.map((row) => ({
      itemId: row.item_id,
      itemLabel: row.item_label,
    })),
    parties: parties.map((row) => ({
      id: row.id,
      agentId: row.agent_id,
      agentLabel: row.agent_label,
      role: row.role,
    })),
    actions: actions.map((row) => ({
      id: row.id,
      sequenceNumber: row.sequence_number,
      actionKind: row.action_kind,
      description: row.description,
      occurred: toRestitutionDate(row.occurred_start, row.occurred_end, row.occurred_precision),
      parties: partiesByAction.get(row.id) ?? [],
      documents: documentsByAction.get(row.id) ?? [],
    })),
    otherDocuments: documents
      .filter((row) => !linkedDocumentIds.has(row.id))
      .map((row) => ({
        id: row.id,
        sourceId: row.source_id,
        sourceLabel: row.source_label,
        documentRole: row.document_role,
      })),
  };
}
