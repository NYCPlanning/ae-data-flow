import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
]);
export type Build = z.infer<typeof buildSchema>;


export const buildDef = z.object({
  name: z.string(),
  dependencies: z.array(buildSchema),
  depenents: z.array(buildSchema)
});
export type BuildDef = z.infer<typeof buildDef>;


const mybuilddef: BuildDef = {
  name: "hi",
  dependencies: ["all", "admin"],
  depenents: ["pluto"]
}

export const buildMap = z.array(buildDef)