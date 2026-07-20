import type { ProvenanceEvent, ProvenanceStatement } from "./provenance";

function literalRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  return value as Record<string, unknown>;
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

export function orderProvenanceEvents(events: readonly ProvenanceEvent[]): ProvenanceEvent[] {
  const byId = new Map(events.map((event) => [event.id, event]));
  const followers = new Map<string, Set<string>>();
  const indegree = new Map(events.map((event) => [event.id, 0]));

  for (const event of events) {
    for (const statement of event.statements) {
      if (
        statement.predicate !== "preceded_by" ||
        !statement.objectEntityId ||
        !byId.has(statement.objectEntityId)
      ) {
        continue;
      }

      const predecessorId = statement.objectEntityId;
      const eventFollowers = followers.get(predecessorId) ?? new Set<string>();
      if (!eventFollowers.has(event.id)) {
        eventFollowers.add(event.id);
        followers.set(predecessorId, eventFollowers);
        indegree.set(event.id, (indegree.get(event.id) ?? 0) + 1);
      }
    }
  }

  const compare = (a: ProvenanceEvent, b: ProvenanceEvent) =>
    a.workingLabel.localeCompare(b.workingLabel);
  const ready = events.filter((event) => indegree.get(event.id) === 0).sort(compare);
  const ordered: ProvenanceEvent[] = [];

  while (ready.length > 0) {
    const event = ready.shift();
    if (!event) {
      break;
    }
    ordered.push(event);

    for (const followerId of followers.get(event.id) ?? []) {
      const nextIndegree = (indegree.get(followerId) ?? 0) - 1;
      indegree.set(followerId, nextIndegree);
      if (nextIndegree === 0) {
        const follower = byId.get(followerId);
        if (follower) {
          ready.push(follower);
          ready.sort(compare);
        }
      }
    }
  }

  if (ordered.length === events.length) {
    return ordered;
  }

  const orderedIds = new Set(ordered.map((event) => event.id));
  return [...ordered, ...events.filter((event) => !orderedIds.has(event.id)).sort(compare)];
}
