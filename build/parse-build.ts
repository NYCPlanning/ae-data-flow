import { Build, buildSchema, buildTree } from "./schemas";
import cloneDeep from "lodash.clonedeep";

function compileBuilds({
  buildName,
  selectedBuilds,
  searchedBuilds,
  searchParents,
  searchChildren,
}: {
  buildName: Build;
  selectedBuilds: Array<Build>;
  searchedBuilds: Array<Build>;
  searchParents: boolean;
  searchChildren: boolean;
}) {
  let nextSelectedBuilds = cloneDeep(selectedBuilds);
  let nextSearchedBuilds = cloneDeep(searchedBuilds);
  if (searchedBuilds.includes(buildName))
    return [nextSelectedBuilds, nextSearchedBuilds];
  nextSearchedBuilds = searchedBuilds.concat([buildName]);

  const buildNode = buildTree.find((build) => build.name === buildName);
  if (buildNode === undefined) throw new Error();
  const { name, parents, children } = buildNode;

  if (searchParents)
    parents.forEach((parent) => {
      [nextSelectedBuilds] = compileBuilds({
        buildName: parent,
        selectedBuilds: nextSelectedBuilds,
        searchedBuilds: nextSearchedBuilds,
        searchParents: true,
        searchChildren: false,
      });
    });

  if (!nextSelectedBuilds.includes(name)) {
    nextSelectedBuilds = nextSelectedBuilds.concat([name]);
  }

  if (searchChildren)
    children.forEach((child) => {
      [nextSelectedBuilds] = compileBuilds({
        buildName: child,
        selectedBuilds: nextSelectedBuilds,
        searchedBuilds: nextSearchedBuilds,
        searchParents: searchParents,
        searchChildren: true,
      });
    });
  return [nextSelectedBuilds, nextSearchedBuilds];
}

export let buildSources: Array<Build> = [];
export let buildTargets: Array<Build> = [];

const buildName = buildSchema.parse(process.env.BUILD);
if (buildName === "all") {
  let selectedSources: Array<Build> = [];
  let searchedSources: Array<Build> = [];
  buildTree.forEach((build) => {
    const prevSelectedSources = cloneDeep(selectedSources);
    const prevSearchSources = cloneDeep(searchedSources);
    [selectedSources, searchedSources] = compileBuilds({
      buildName: build.name,
      selectedBuilds: prevSelectedSources,
      searchedBuilds: prevSearchSources,
      searchParents: true,
      searchChildren: true,
    });
  });
  buildSources = cloneDeep(selectedSources);
  buildTargets = cloneDeep(selectedSources);
} else {
  [buildSources] = compileBuilds({
    buildName: buildName,
    selectedBuilds: [],
    searchedBuilds: [],
    searchParents: true,
    searchChildren: true,
  });

  [buildTargets] = compileBuilds({
    buildName: buildName,
    selectedBuilds: [],
    searchedBuilds: [],
    searchParents: false,
    searchChildren: true,
  });
}

console.log("Build step: buildSources", buildSources);
console.log("Build step: buildTargets", buildTargets);
