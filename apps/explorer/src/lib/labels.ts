import { isHttpReference } from "./presentation";

export function predicatePhrase(predicate: string): string {
  return predicate === "possibly_same_as" ? "possibly the same as" : predicate.replaceAll("_", " ");
}

export function predicateLabel(predicate: string): string {
  if (predicate === "has_name") {
    return "Name";
  }

  const phrase = predicatePhrase(predicate);
  return phrase.charAt(0).toUpperCase() + phrase.slice(1);
}

export function formatSourceLabel(label: string): string {
  if (isHttpReference(label)) {
    const url = new URL(label);
    const segment = url.pathname.split("/").filter(Boolean).at(-1) ?? "";
    const readable = decodeURIComponent(segment).replaceAll("_", " ").trim();
    const host = url.hostname.replace(/^www\./, "");
    return readable ? `${host} · ${readable}` : host;
  }

  if (label.includes("/")) {
    const basename = label.split("/").filter(Boolean).at(-1)?.trim();
    return basename || label;
  }

  return label;
}
