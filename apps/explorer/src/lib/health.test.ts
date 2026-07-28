import { describe, expect, it } from "vitest";
import {
  isAuthorizedHealthRequest,
  liveResponse,
  notReadyResponse,
  readyResponse,
  requireHealthcheckToken,
  unauthorizedHealthResponse,
} from "./health";

describe("requireHealthcheckToken", () => {
  it("requires a token in production", () => {
    expect(() => requireHealthcheckToken(undefined, "production")).toThrow(
      "HEALTHCHECK_TOKEN is required in production.",
    );
  });

  it("allows a missing token outside production", () => {
    expect(requireHealthcheckToken(undefined, "development")).toBeUndefined();
  });

  it("returns a trimmed token when present", () => {
    expect(requireHealthcheckToken("  secret  ", "production")).toBe("secret");
  });
});

describe("isAuthorizedHealthRequest", () => {
  it("rejects missing or wrong tokens without querying postgres", () => {
    const expected = "health-secret-token";

    expect(isAuthorizedHealthRequest(new Request("http://127.0.0.1/livez"), expected)).toBe(false);
    expect(
      isAuthorizedHealthRequest(
        new Request("http://127.0.0.1/livez", {
          headers: { "X-Health-Token": "wrong-secret-token" },
        }),
        expected,
      ),
    ).toBe(false);
    expect(
      isAuthorizedHealthRequest(
        new Request("http://127.0.0.1/livez", {
          headers: { "X-Health-Token": "short" },
        }),
        expected,
      ),
    ).toBe(false);
  });

  it("accepts a matching token", () => {
    const expected = "health-secret-token";
    const request = new Request("http://127.0.0.1/readyz", {
      headers: { "X-Health-Token": expected },
    });

    expect(isAuthorizedHealthRequest(request, expected)).toBe(true);
  });

  it("rejects when no expected token is configured", () => {
    const request = new Request("http://127.0.0.1/readyz", {
      headers: { "X-Health-Token": "anything" },
    });

    expect(isAuthorizedHealthRequest(request, undefined)).toBe(false);
  });
});

describe("health responses", () => {
  it("returns uninformative unauthorized and readiness statuses", () => {
    expect(unauthorizedHealthResponse().status).toBe(404);
    expect(liveResponse().status).toBe(204);
    expect(readyResponse().status).toBe(204);
    expect(notReadyResponse().status).toBe(503);
  });
});
