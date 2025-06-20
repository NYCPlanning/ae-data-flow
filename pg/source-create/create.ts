import { exit } from "process";
import { Build, buildArrayExample, buildSchema, searchDependencies } from "../../schemas";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";

(async () => {
  const build = buildSchema.parse(process.env.BUILD);

  type Source = {
    fileName: string;
    builds: Array<Build>;
  };

  const sources: Array<Source> = [
    {
      fileName: "borough",
      builds: ["admin", "pluto"],
    },
    {
      fileName: "admin",
      builds: ["admin"],
    },
    {
      fileName: "capital-planning",
      builds: ["capital-planning"],
    },
    {
      fileName: "pluto",
      builds: ["pluto"],
    },
  ];

  const newSources = buildArrayExample;
  const newBuildSources = build === "all" ? newSources
    : newSources.filter((newSource) => newSource.name === build);

    console.log(newBuildSources);

  const buildSources =
    build === "all"
      ? sources
      : sources.filter((source) => source.builds.includes(build));

  const sourceDependenciesAndDependents: string[] = [];
  const currentBuild = newBuildSources.find((source) => source.name === build);
  if (currentBuild) {
      searchDependencies(currentBuild, sourceDependenciesAndDependents);
  }
  console.log("parent and child walk", sourceDependenciesAndDependents);

  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");
    
    buildSources.forEach(async (source) => {
      const sql = fs
        .readFileSync(`pg/source-create/${source.fileName}.sql`)
        .toString();
      await pgClient.query(sql);
      console.debug("source", source.fileName);
    });

    newBuildSources.forEach(async (newSource) => {
      const sql = fs
        .readFileSync(`pg/source-create/${newSource.name}.sql`)
        .toString();
      await pgClient.query(sql);
      console.debug("new source", newSource.name);
    });


    await pgClient.query("COMMIT;");
  } catch (e) {
    await pgClient.query("ROLLBACK;");
    console.error(e);
  } finally {
    console.debug("ending");
    await pgClient.end();
    exit();
  }
})();
