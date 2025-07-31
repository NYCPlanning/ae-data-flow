import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "agencies",
  "boroughs",
  "community-districts",
  "community-board-budget-requests",
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
    children: ["community-board-budget-requests", "capital-planning"],
  },
  {
    name: "boroughs",
    parents: [],
    children: [
      "community-districts",
      "community-board-budget-requests",
      "pluto",
    ],
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
    parents: ["agencies", "boroughs", "community-districts"],
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
