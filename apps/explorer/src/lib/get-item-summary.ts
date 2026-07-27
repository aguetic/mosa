import { buildItemSummary, type ItemSummary } from "./object-summary";
import { getProvenanceEventsForItem } from "./provenance";
import type { EntityDetail } from "./queries";
import { getClaimsForEntity, getEntity } from "./queries";
import { getRestitutionCasesForItem, getRestitutionDocumentsForItem } from "./restitution";

export async function getItemSummary(itemId: string): Promise<{
  entity: EntityDetail;
  summary: ItemSummary;
} | null> {
  const entity = await getEntity(itemId);
  if (entity?.entityType !== "item") {
    return null;
  }

  const [claims, provenanceEvents, restitutionCases, restitutionDocuments] = await Promise.all([
    getClaimsForEntity(itemId),
    getProvenanceEventsForItem(itemId),
    getRestitutionCasesForItem(itemId),
    getRestitutionDocumentsForItem(itemId),
  ]);

  return {
    entity,
    summary: buildItemSummary({
      itemId,
      claims,
      identifiers: entity.identifiers,
      provenanceEvents,
      restitutionCases,
      restitutionDocuments,
    }),
  };
}
