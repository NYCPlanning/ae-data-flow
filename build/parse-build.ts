import { Build, BuildNode, buildSchema, buildTree } from "./schemas";

function compileBuilds(buildName: Build, buildSources: Array<Build>, searchedBuilds: Array<Build>) {
  if (searchedBuilds.includes(buildName)) return [buildSources, searchedBuilds];
  searchedBuilds = searchedBuilds.concat([buildName])

  const buildNode = buildTree.find((build) => build.name === buildName)
  if (buildNode === undefined) throw new Error();
  const { name, dependencies, dependents } = buildNode

  dependencies.forEach((dependency) => {
    [buildSources] = compileBuilds(dependency, buildSources, searchedBuilds)
  })

  if (!buildSources.includes(name)) {
    buildSources = buildSources.concat([name])
  }

  dependents.forEach((dependent) => {
    [buildSources] = compileBuilds(dependent, buildSources, searchedBuilds)
  })
  return [buildSources, searchedBuilds];
}

export let buildSources: Array<Build> = [];
let searchedBuilds: Array<Build> = []

const buildName = buildSchema.parse(process.env.BUILD);
if (buildName === "all") {
  buildTree.forEach((build) => {
    [buildSources, searchedBuilds] = compileBuilds(build.name, buildSources, searchedBuilds);
  });
} else {
  [buildSources] = compileBuilds(buildName, buildSources, searchedBuilds);
}

console.log("Build step: buildSources", buildSources);
