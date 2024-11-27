import { pgEnum } from "drizzle-orm/pg-core";

export const capital_project_category = pgEnum("capital_project_category", [
  "Fixed Asset",
  "Lump Sum",
  "ITT, Vehicles and Equipment",
]);
export const category = pgEnum("category", [
  "Residential",
  "Commercial",
  "Manufacturing",
]);
