import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "community-districts",
  "city-council-districts",
  "borough",
]);
export type Build = z.infer<typeof buildSchema>;


export const buildDef = z.object({
  name: z.string(),
  dependencies: z.array(buildSchema),
  dependents: z.array(buildSchema)
});
export type BuildDef = z.infer<typeof buildDef>;

export const buildDefmap = z.object({
  dependencies: z.array(buildSchema),
  dependents: z.array(buildSchema)
});
export type BuildDefmap = z.infer<typeof buildDefmap>;

// make a map of 
const mybuilddef: BuildDef = {
  name: "hi",
  dependencies: ["all", "admin"],
  dependents: ["pluto"]
}


export const buildArrayExample: Array<BuildDef> = [
  {
    name: "borough",
    dependencies: [],
    dependents: ["community-districts", "pluto"]
  },
  {
    name: "pluto",
    dependencies: ["borough"],
    dependents: [],
  },
  {
    name: "community-districts",
    dependencies: ["borough"],
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

export const buildMap = new Map<Build, BuildDefmap>(
  [
    [
      "borough", 
      {
        dependencies: [],
        dependents: ["community-districts", "pluto"]
      }
    ],
    [
      "pluto", 
      {
        dependencies: ["borough"],
        dependents: []
      }
    ],
    [
      "community-districts", 
      {
        dependencies: ["borough"],
        dependents: []
      }
    ],
    [
      "city-council-districts", 
      {
        dependencies: [],
        dependents: []
      }
    ],
    [
      "capital-planning", 
      {
        dependencies: [],
        dependents: []
      }
    ],
  ]
);