// Drizzle kit configuration
import type { Config } from "drizzle-kit";

export default {
  schema: "./drizzle/schema/*",
  dialect: "postgresql",
  out: "./drizzle/migration",
  dbCredentials: {
    host: process.env.API_DATABASE_HOST!,
    port: parseInt(process.env.API_DATABASE_PORT!),
    user: process.env.API_DATABASE_USER,
    password: process.env.API_DATABASE_PASSWORD,
    database: process.env.API_DATABASE_NAME!,
    ssl: process.env.API_DATABASE_ENV !== "development" && {
      rejectUnauthorized: false,
    },
  },
} satisfies Config;
