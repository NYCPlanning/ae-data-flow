import { z } from "zod";

export const buildSchema = z.enum(["admin", "capital-planning", "pluto"]);
export type Build = z.infer<typeof buildSchema>;
