import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "boroughs",
  "community-districts",
  "pluto",
  "city-council-districts",
  "capital-planning",
]);
export type Build = z.infer<typeof buildSchema>;

export const buildNode = z.object({
  name: buildSchema,
  dependencies: z.array(buildSchema),
  dependents: z.array(buildSchema)
});
export type BuildNode = z.infer<typeof buildNode>;

export const buildTree: Array<BuildNode> = [
  {
    name: "boroughs",
    dependencies: [],
    dependents: ["community-districts", "pluto"]
  },
  {
    name: "pluto",
    dependencies: ["boroughs"],
    dependents: [],
  },
  {
    name: "community-districts",
    dependencies: ["boroughs"],
    dependents: [],
  },
  {
    name: "city-council-districts",
    dependencies: [],
    dependents: [],
  },
  {
    name: "capital-planning",
    dependencies: [],
    dependents: [],
  }
];
