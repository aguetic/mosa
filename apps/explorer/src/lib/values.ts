export interface ExternalIdentifier {
  namespace: string;
  value: string;
  sourceId: string | null;
  sourceLabel: string | null;
}

export function parseIdentifiers(value: unknown): ExternalIdentifier[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.flatMap((entry) => {
    if (!entry || typeof entry !== "object") {
      return [];
    }

    const record = entry as Record<string, unknown>;
    if (typeof record.namespace !== "string" || typeof record.value !== "string") {
      return [];
    }

    return [
      {
        namespace: record.namespace,
        value: record.value,
        sourceId: typeof record.source_id === "string" ? record.source_id : null,
        sourceLabel: typeof record.source_label === "string" ? record.source_label : null,
      },
    ];
  });
}

export function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/iu.test(value);
}
