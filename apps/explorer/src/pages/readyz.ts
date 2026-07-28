import { HEALTHCHECK_TOKEN } from "astro:env/server";
import type { APIRoute } from "astro";
import { query } from "../lib/database";
import {
  isAuthorizedHealthRequest,
  notReadyResponse,
  readyResponse,
  requireHealthcheckToken,
  unauthorizedHealthResponse,
} from "../lib/health";

export const prerender = false;

const READY_CHECK_TIMEOUT_MS = 2_000;

export const GET: APIRoute = async ({ request }) => {
  const token = requireHealthcheckToken(HEALTHCHECK_TOKEN, process.env.NODE_ENV);
  if (!isAuthorizedHealthRequest(request, token)) {
    return unauthorizedHealthResponse();
  }

  try {
    await Promise.race([
      query("select 1"),
      new Promise<never>((_, reject) => {
        setTimeout(() => {
          reject(new Error("readyz database check timed out"));
        }, READY_CHECK_TIMEOUT_MS);
      }),
    ]);
    return readyResponse();
  } catch {
    return notReadyResponse();
  }
};
