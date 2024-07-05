// Drizzle kit configuration
import type { Config } from "drizzle-kit";

export default {
  schema: "./drizzle/schema/*",
  dialect: "postgresql",
  out: "./drizzle/migration",
  dbCredentials: {
    host: process.env.DRIZZLE_DATABASE_HOST!,
    port: parseInt(process.env.DRIZZLE_DATABASE_PORT!),
    user: process.env.DRIZZLE_DATABASE_USER,
    password: process.env.DRIZZLE_DATABASE_PASSWORD,
    database: process.env.DRIZZLE_DATABASE_NAME!,
    ssl: process.env.DRIZZLE_DATABASE_ENV !== "development" && {
      rejectUnauthorized: false,
    },
  },
} satisfies Config;
