import { HEALTHCHECK_TOKEN } from "astro:env/server";
import type { APIRoute } from "astro";
import {
  isAuthorizedHealthRequest,
  liveResponse,
  requireHealthcheckToken,
  unauthorizedHealthResponse,
} from "../lib/health";

export const prerender = false;

export const GET: APIRoute = ({ request }) => {
  const token = requireHealthcheckToken(HEALTHCHECK_TOKEN, process.env.NODE_ENV);
  if (!isAuthorizedHealthRequest(request, token)) {
    return unauthorizedHealthResponse();
  }

  return liveResponse();
};
