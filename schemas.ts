import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "budget-request",
]);
export type Build = z.infer<typeof buildSchema>;
