import node from "@astrojs/node";
import { defineConfig, envField } from "astro/config";

export default defineConfig({
  output: "server",
  adapter: node({ mode: "standalone" }),
  env: {
    schema: {
      DATABASE_URL: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
      DATABASE_SSL_CA: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
      DATABASE_POOL_SIZE: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
      DATABASE_STATEMENT_TIMEOUT_MS: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
      // Deprecated local-development alias for DATABASE_URL.
      LOCAL_DATABASE_URL: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
    },
  },
});
