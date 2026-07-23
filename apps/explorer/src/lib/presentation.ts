import type { ClaimDetail } from "./queries";

export function formatDate(value: Date | string | null): string | null {
  if (!value) {
    return null;
  }

  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.valueOf())) {
    return String(value);
  }

  return new Intl.DateTimeFormat("en-GB", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: "UTC",
  }).format(date);
}

function literalRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  return value as Record<string, unknown>;
}

function dateRangeLabel(earliest?: string, latest?: string): string | null {
  if (earliest && latest) {
    return earliest === latest ? earliest : `${earliest}–${latest}`;
  }

  return earliest ?? latest ?? null;
}

/** Formats structured claim literals for presentation. Raw JSON remains on claim detail pages. */
export function formatLiteralValue(value: unknown): string | null {
  const record = literalRecord(value);
  if (!record) {
    return typeof value === "string" ? value : null;
  }

  if (record.type === "date_interval") {
    const range = dateRangeLabel(
      typeof record.earliest === "string" ? record.earliest : undefined,
      typeof record.latest === "string" ? record.latest : undefined,
    );
    const interpretation =
      typeof record.interpretation === "string" ? record.interpretation : undefined;
    const alternatives = Array.isArray(record.alternatives)
      ? record.alternatives.filter((entry): entry is string => typeof entry === "string")
      : [];

    if (interpretation === "approximate" || interpretation === "approximate_range") {
      return range ? `Approximately ${range}` : "Approximate date";
    }

    if (interpretation === "alternatives" || alternatives.length > 0) {
      if (alternatives.length > 0) {
        return alternatives.join(" or ");
      }
    }

    if (typeof record.verbatim === "string") {
      return record.verbatim;
    }

    return range;
  }

  if (typeof record.value === "string") {
    return record.value;
  }

  return null;
}

export function literalLabel(claim: ClaimDetail): string {
  // date_interval literals have no `value` field, so the SQL display extraction is null.
  // Format them from structure before falling back to a raw display string or JSON.
  if (
    claim.literalValue &&
    typeof claim.literalValue === "object" &&
    !Array.isArray(claim.literalValue) &&
    (claim.literalValue as { type?: string }).type === "date_interval"
  ) {
    const formatted = formatLiteralValue(claim.literalValue);
    if (formatted) {
      return formatted;
    }
  }

  if (claim.literalDisplayValue) {
    return claim.literalDisplayValue;
  }

  if (claim.literalValue === null || claim.literalValue === undefined) {
    return "Empty literal";
  }

  const formatted = formatLiteralValue(claim.literalValue);
  if (formatted) {
    return formatted;
  }

  return typeof claim.literalValue === "string"
    ? claim.literalValue
    : JSON.stringify(claim.literalValue);
}

export function isHttpReference(value: string | null): boolean {
  if (!value) {
    return false;
  }

  try {
    const url = new URL(value);
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
}
