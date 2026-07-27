import type { QueryResultRow } from "pg";
import { query } from "./database";
import { type ExternalIdentifier, parseIdentifiers } from "./values";

export type { ExternalIdentifier };

export const ENTITY_TYPES = ["item", "agent", "place", "source", "event"] as const;
export type EntityType = (typeof ENTITY_TYPES)[number];

export type DisplayLabelBasis =
  | "has_name"
  | "external_identifier"
  | "source_reference"
  | "event_summary"
  | "entity_id";

export interface EntitySummary {
  id: string;
  entityType: EntityType;
  displayLabel: string;
  displayLabelBasis: DisplayLabelBasis;
  displayLabelClaimId: string | null;
  subtypeKind: string | null;
  identifiers: ExternalIdentifier[];
}

export interface EntityDetail extends EntitySummary {
  reference: string | null;
  retrievedAt: Date | string | null;
}

export interface ClaimEvidence {
  id: string;
  sourceId: string;
  sourceLabel: string;
  relationship: string;
  locator: string | null;
  excerpt: string | null;
  notes: string | null;
}

export interface ClaimDetail {
  id: string;
  subjectId: string;
  subjectLabel: string;
  subjectType: EntityType;
  predicate: string;
  valueKind: "entity" | "literal";
  objectEntityId: string | null;
  objectEntityLabel: string | null;
  objectEntityType: EntityType | null;
  objectPlaceKind: string | null;
  literalValue: unknown;
  literalDisplayValue: string | null;
  literalLanguage: string | null;
  assertedByAgentId: string | null;
  assertedByLabel: string | null;
  status: string;
  supersedesClaimId: string | null;
  notes: string | null;
  createdAt: Date | string;
  evidence: ClaimEvidence[];
}

interface EntityRow extends QueryResultRow {
  id: string;
  entity_type: EntityType;
  display_label: string;
  display_label_basis: DisplayLabelBasis;
  display_label_claim_id: string | null;
  subtype_kind: string | null;
  reference?: string | null;
  retrieved_at?: Date | string | null;
  identifiers: unknown;
}

interface ClaimRow extends QueryResultRow {
  claim_id: string;
  subject_id: string;
  subject_label: string;
  subject_type: EntityType;
  predicate: string;
  value_kind: "entity" | "literal";
  object_entity_id: string | null;
  object_entity_label: string | null;
  object_entity_type: EntityType | null;
  object_place_kind: string | null;
  literal_value: unknown;
  literal_display_value: string | null;
  literal_language: string | null;
  asserted_by_agent_id: string | null;
  asserted_by_label: string | null;
  status: string;
  supersedes_claim_id: string | null;
  notes: string | null;
  created_at: Date | string;
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

function toEntitySummary(row: EntityRow): EntitySummary {
  return {
    id: row.id,
    entityType: row.entity_type,
    displayLabel: row.display_label,
    displayLabelBasis: row.display_label_basis,
    displayLabelClaimId: row.display_label_claim_id,
    subtypeKind: row.subtype_kind,
    identifiers: parseIdentifiers(row.identifiers),
  };
}

function toEvidence(row: EvidenceRow): ClaimEvidence {
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

function toClaim(
  row: ClaimRow,
  evidenceByClaim: ReadonlyMap<string, ClaimEvidence[]>,
): ClaimDetail {
  return {
    id: row.claim_id,
    subjectId: row.subject_id,
    subjectLabel: row.subject_label,
    subjectType: row.subject_type,
    predicate: row.predicate,
    valueKind: row.value_kind,
    objectEntityId: row.object_entity_id,
    objectEntityLabel: row.object_entity_label,
    objectEntityType: row.object_entity_type,
    objectPlaceKind: row.object_place_kind,
    literalValue: row.literal_value,
    literalDisplayValue: row.literal_display_value,
    literalLanguage: row.literal_language,
    assertedByAgentId: row.asserted_by_agent_id,
    assertedByLabel: row.asserted_by_label,
    status: row.status,
    supersedesClaimId: row.supersedes_claim_id,
    notes: row.notes,
    createdAt: row.created_at,
    evidence: evidenceByClaim.get(row.claim_id) ?? [],
  };
}

const ENTITY_SELECT = `
  select
      e.id::text,
      e.entity_type,
      display.display_label,
      display.display_label_basis,
      display.display_label_claim_id::text,
      case e.entity_type
          when 'item' then i.item_kind
          when 'agent' then a.agent_kind
          when 'place' then p.place_kind
          when 'source' then s.source_kind
          when 'event' then event.event_kind
      end as subtype_kind,
      s.reference,
      s.retrieved_at,
      coalesce(ids.identifiers, '[]'::jsonb) as identifiers
  from entities.entity as e
  join entities.entity_display as display on display.id = e.id
  left join entities.item as i on i.id = e.id
  left join entities.agent as a on a.id = e.id
  left join entities.place as p on p.id = e.id
  left join entities.source as s on s.id = e.id
  left join provenance.event as event on event.id = e.id
  left join lateral (
      select jsonb_agg(
          jsonb_build_object(
              'namespace', identifier.namespace,
              'value', identifier.value,
              'source_id', identifier.source_id,
              'source_label', identifier_source_display.display_label
          )
          order by identifier.namespace, identifier.value
      ) as identifiers
      from entities.external_identifier as identifier
      left join entities.entity_display as identifier_source_display
          on identifier_source_display.id = identifier.source_id
      where identifier.entity_id = e.id
  ) as ids on true
`;

export async function searchEntities(
  searchText: string,
  entityType: EntityType | null,
): Promise<EntitySummary[]> {
  const rows = await query<EntityRow>(
    `${ENTITY_SELECT}
     where (
         $1::text = ''
         or strpos(entities.search_normalise(display.display_label), entities.search_normalise($1)) > 0
         or exists (
             select 1
             from knowledge.claim as name_claim
             where name_claim.subject_id = e.id
               and name_claim.predicate = 'has_name'
               and name_claim.status = 'active'
               and strpos(
                   entities.search_normalise(coalesce(name_claim.literal_value ->> 'value', '')),
                   entities.search_normalise($1)
               ) > 0
         )
         or exists (
             select 1
             from entities.external_identifier as search_identifier
             where search_identifier.entity_id = e.id
               and (
                   strpos(entities.search_normalise(search_identifier.value), entities.search_normalise($1)) > 0
                   or strpos(entities.search_normalise(search_identifier.namespace), entities.search_normalise($1)) > 0
               )
         )
         or (
             e.entity_type = 'source'
             and s.reference is not null
             and strpos(entities.search_normalise(s.reference), entities.search_normalise($1)) > 0
         )
     )
       and ($2::text is null or e.entity_type = $2)
     order by display.display_label, e.id
     limit 100`,
    [searchText.trim(), entityType],
  );

  return rows.map(toEntitySummary);
}

export async function getEntity(id: string): Promise<EntityDetail | null> {
  const rows = await query<EntityRow>(
    `${ENTITY_SELECT}
     where e.id = $1::uuid`,
    [id],
  );
  const row = rows[0];

  if (!row) {
    return null;
  }

  return {
    ...toEntitySummary(row),
    reference: row.reference ?? null,
    retrievedAt: row.retrieved_at ?? null,
  };
}

async function getEvidenceForClaims(
  claimIds: readonly string[],
): Promise<Map<string, ClaimEvidence[]>> {
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

  const evidenceByClaim = new Map<string, ClaimEvidence[]>();
  for (const row of rows) {
    const evidence = evidenceByClaim.get(row.claim_id) ?? [];
    evidence.push(toEvidence(row));
    evidenceByClaim.set(row.claim_id, evidence);
  }

  return evidenceByClaim;
}

const CLAIM_SELECT = `
  select
      details.claim_id::text,
      details.subject_id::text,
      details.subject_label,
      details.subject_type,
      details.predicate,
      details.value_kind,
      details.object_entity_id::text,
      details.object_entity_label,
      details.object_entity_type,
      place.place_kind as object_place_kind,
      details.literal_value,
      details.literal_display_value,
      details.literal_language,
      details.asserted_by_agent_id::text,
      details.asserted_by_label,
      details.status,
      details.supersedes_claim_id::text,
      details.notes,
      details.created_at
  from knowledge.claim_details as details
  left join entities.place as place
    on place.id = details.object_entity_id
`;

export async function getClaimsForEntity(id: string): Promise<ClaimDetail[]> {
  const rows = await query<ClaimRow>(
    `${CLAIM_SELECT}
     where details.subject_id = $1::uuid or details.object_entity_id = $1::uuid
     order by details.created_at, details.claim_id`,
    [id],
  );
  const evidenceByClaim = await getEvidenceForClaims(rows.map((row) => row.claim_id));

  return rows.map((row) => toClaim(row, evidenceByClaim));
}

export async function getClaim(id: string): Promise<ClaimDetail | null> {
  const rows = await query<ClaimRow>(
    `${CLAIM_SELECT}
     where details.claim_id = $1::uuid`,
    [id],
  );
  const row = rows[0];

  if (!row) {
    return null;
  }

  const evidenceByClaim = await getEvidenceForClaims([row.claim_id]);
  return toClaim(row, evidenceByClaim);
}

export function isEntityType(value: string): value is EntityType {
  return (ENTITY_TYPES as readonly string[]).includes(value);
}
