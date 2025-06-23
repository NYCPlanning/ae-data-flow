import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "community-districts",
  "city-council-districts",
  "boroughs",
  // "cbbr",
  // "agencies",
]);
export type Build = z.infer<typeof buildSchema>;

export const buildDef = z.object({
  name: buildSchema,
  dependencies: z.array(buildSchema),
  dependents: z.array(buildSchema)
});
export type BuildDef = z.infer<typeof buildDef>;

export const buildList: Array<BuildDef> = [
  {
    name: "boroughs",
    dependencies: [],
    dependents: ["community-districts", "pluto"]
  },
  // {
  //   name: "agencies",
  //   dependencies: [],
  //   dependents: ["cbbr", "capital-planning"],
  // },
  {
    name: "pluto",
    dependencies: ["boroughs"],
    dependents: [],
  },
  {
    name: "community-districts",
    dependencies: ["boroughs"],
    // dependents: ["cbbr"],
    dependents: [],
  },
  // {
  //   name: "cbbr",
  //   dependencies: ["community-districts", "agencies"],
  //   dependents: [],
  // },
  {
    name: "city-council-districts",
    dependencies: [],
    dependents: [],
  },
  {
    name: "capital-planning",
    // dependencies: ["agencies"],
    dependencies: [],
    dependents: [],
  }
];

export let buildSources: string[] = [];
export let buildDependentSources: string[] = [];

function searchDependencies(build: BuildDef) {
  if (build.dependencies.length === 0 && !buildSources.includes(build.name)) {
    buildSources.push(build.name);
    return;
  }

  build.dependencies.forEach((dependency) => {
    const currBuild = buildList.find((build) => build.name === dependency);
    if (!currBuild) {
      console.error("No such build");
      return;
    }
    searchDependencies(currBuild);
  });

  if (!buildSources.includes(build.name)) {
    buildSources.push(build.name);
  }
}

function searchDependents(build: BuildDef) {
  if (!buildDependentSources.includes(build.name)) {
    buildDependentSources.push(build.name);
  }
  
  if (!buildSources.includes(build.name)) {
    buildSources.push(build.name);
  }

  if (build.dependents.length > 0) {
    build.dependents.forEach((dependent) => {
      const currentBuild = buildList.find((build) => build.name === dependent);
      if (!currentBuild) {
        return;
      }
      searchDependents(currentBuild);
    });
  }
}

const build = buildSchema.parse(process.env.BUILD);
if (build === "all") {
  buildList.forEach((b) => {
    searchDependencies(b);
    searchDependents(b)
  })
} else {
  const inputBuild = buildList.find((b) => b.name === build);
  if (inputBuild) {
    searchDependencies(inputBuild);
    searchDependents(inputBuild);
  } else {
    console.error("Build not found");
  }
}