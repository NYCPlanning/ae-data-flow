// Drizzle kit configuration
import type { Config } from "drizzle-kit";

export default {
  schema: "./drizzle/migration/schema.ts",
  dialect: "postgresql",
  out: "./drizzle/migration",
  dbCredentials: {
    host: process.env.FLOW_DATABASE_HOST!,
    port: parseInt(process.env.FLOW_DATABASE_PORT!),
    user: process.env.FLOW_DATABASE_USER,
    password: process.env.FLOW_DATABASE_PASSWORD,
    database: process.env.FLOW_DATABASE_NAME!,
    ssl: process.env.FLOW_DATABASE_ENV !== "development" && {
      rejectUnauthorized: false,
    },
  },
} satisfies Config;
