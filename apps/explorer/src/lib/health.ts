import { timingSafeEqual } from "node:crypto";

const HEALTH_TOKEN_HEADER = "x-health-token";

export function isAuthorizedHealthRequest(
  request: Request,
  expectedToken: string | undefined,
): boolean {
  const expected = expectedToken?.trim();
  if (!expected) {
    return false;
  }

  const provided = request.headers.get(HEALTH_TOKEN_HEADER);
  if (!provided) {
    return false;
  }

  const expectedBuffer = Buffer.from(expected);
  const providedBuffer = Buffer.from(provided);
  if (expectedBuffer.length !== providedBuffer.length) {
    return false;
  }

  return timingSafeEqual(expectedBuffer, providedBuffer);
}

export function requireHealthcheckToken(
  token: string | undefined,
  nodeEnv: string | undefined,
): string | undefined {
  const trimmed = token?.trim();
  if (trimmed) {
    return trimmed;
  }

  if (nodeEnv === "production") {
    throw new Error("HEALTHCHECK_TOKEN is required in production.");
  }

  return undefined;
}

export function unauthorizedHealthResponse(): Response {
  return new Response(null, { status: 404 });
}

export function liveResponse(): Response {
  return new Response(null, { status: 204 });
}

export function readyResponse(): Response {
  return new Response(null, { status: 204 });
}

export function notReadyResponse(): Response {
  return new Response(null, { status: 503 });
}
