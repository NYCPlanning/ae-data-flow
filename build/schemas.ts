import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "agencies",
  "boroughs",
  "community-board-budget-requests",
  "community-districts",
  "pluto",
  "city-council-districts",
  "capital-planning",
]);
export type Build = z.infer<typeof buildSchema>;

export const buildNode = z.object({
  name: buildSchema,
  parents: z.array(buildSchema),
  children: z.array(buildSchema),
});
export type BuildNode = z.infer<typeof buildNode>;

export const buildTree: Array<BuildNode> = [
  {
    name: "agencies",
    parents: [],
    children: ["capital-planning", "community-board-budget-requests"],
  },
  {
    name: "boroughs",
    parents: [],
    children: ["community-districts", "pluto"],
  },
  {
    name: "capital-planning",
    parents: ["agencies"],
    children: [],
  },
  {
    name: "city-council-districts",
    parents: [],
    children: [],
  },
  {
    name: "community-board-budget-requests",
    parents: ["agencies", "community-districts"],
    children: [],
  },
  {
    name: "community-districts",
    parents: ["boroughs"],
    children: ["community-board-budget-requests"],
  },
  {
    name: "pluto",
    parents: ["boroughs"],
    children: [],
  },
];
