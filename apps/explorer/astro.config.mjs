import node from "@astrojs/node";
import { defineConfig, envField } from "astro/config";

export default defineConfig({
  output: "server",
  adapter: node({ mode: "standalone" }),
  env: {
    schema: {
      LOCAL_DATABASE_URL: envField.string({
        context: "server",
        access: "secret",
        optional: true,
      }),
    },
  },
});
