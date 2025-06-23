import { z } from "zod";

export const buildSchema = z.enum([
  "all",
  "admin",
  "capital-planning",
  "pluto",
  "community-districts",
  "city-council-districts",
  "borough",
  "cbbr",
  "agencies",
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
    name: "borough",
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
    dependencies: ["borough"],
    dependents: [],
  },
  {
    name: "community-districts",
    dependencies: ["borough"],
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
console.log("build from schema", build);
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

console.log("all sources walk", buildSources);
console.log("dependents walk", buildDependentSources);