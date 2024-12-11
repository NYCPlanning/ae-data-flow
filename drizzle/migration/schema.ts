import { pgEnum } from "drizzle-orm/pg-core";

export const category = pgEnum("category", [
  "Residential",
  "Commercial",
  "Manufacturing",
]);
