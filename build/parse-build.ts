import { BuildNode, buildSchema, buildTree } from "./schemas";

export let buildSources: string[] = [];
export let buildDependentSources: string[] = [];

function searchDependencies(build: BuildNode) {
  if (build.dependencies.length === 0 && !buildSources.includes(build.name)) {
    buildSources.push(build.name);
    return;
  }

  build.dependencies.forEach((dependency) => {
    const currBuild = buildTree.find((build) => build.name === dependency);
    if (!currBuild) {
      console.error("No such build");
      return;
    }
    searchDependencies(currBuild);
    searchDependents(currBuild);
  });

  if (!buildSources.includes(build.name)) {
    buildSources.push(build.name);
  }
}

function searchDependents(build: BuildNode) {
  if (!buildDependentSources.includes(build.name)) {
    buildDependentSources.push(build.name);
  }
  
  if (!buildSources.includes(build.name)) {
    buildSources.push(build.name);
  }

  if (build.dependents.length > 0) {
    build.dependents.forEach((dependent) => {
      const currentBuild = buildTree.find((build) => build.name === dependent);
      if (!currentBuild) {
        return;
      }
      searchDependents(currentBuild);
    });
  }
}

const build = buildSchema.parse(process.env.BUILD);
if (build === "all") {
  buildTree.forEach((b) => {
    searchDependencies(b);
    searchDependents(b)
  })
} else {
  const inputBuild = buildTree.find((b) => b.name === build);
  if (inputBuild) {
    searchDependencies(inputBuild);
    searchDependents(inputBuild);
  } else {
    console.error("Build not found");
  }
}

console.log("Build step: buildSources", buildSources);
console.log("Build step: buildDependentSources", buildDependentSources);