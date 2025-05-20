import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "community-board-budget-requests",
]);
export type Build = z.infer<typeof buildSchema>;
