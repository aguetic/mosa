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

export function literalLabel(claim: ClaimDetail): string {
  if (claim.literalDisplayValue) {
    return claim.literalDisplayValue;
  }

  if (claim.literalValue === null || claim.literalValue === undefined) {
    return "Empty literal";
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
