import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "cbbr",
]);
export type Build = z.infer<typeof buildSchema>;
