import { z } from "zod";

export const buildSchema = z.enum(["all", "admin", "capital-planning", "pluto"]);
export type Build = z.infer<typeof buildSchema>;
