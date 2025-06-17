import { exit } from "process";
import { Build, buildSchema, buildMap, buildArrayExample } from "../../schemas";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";

(async () => {
  const build = buildSchema.parse(process.env.BUILD);

  type Source = {
    fileName: string;
    treeDepth: number;
    builds: Array<Build>;
  };

  const sources: Array<Source> = [
    {
      fileName: "borough",
      treeDepth: 0,
      builds: ["admin", "pluto"],
    },
    {
      fileName: "admin",
      treeDepth: 1,
      builds: ["admin"],
    },
    {
      fileName: "capital-planning",
      treeDepth: 0,
      builds: ["capital-planning"],
    },
    {
      fileName: "pluto",
      treeDepth: 1,
      builds: ["pluto"],
    },
  ];

  const newSources = buildArrayExample;
  // console.log("new sources", buildMap);

  // this sorts the the sources in order of ascending tree depth, probably so that we're not buildindg 
  // things that are dependent on others
  const buildSources =
    build === "all"
      ? sources
      : sources.filter((source) => source.builds.includes(build));
  // console.log("unsorted buildSources", buildSources);
  buildSources.sort((a, b) => a.treeDepth - b.treeDepth);
  // console.log("sorted build sources", buildSources);

  const newBuildSources = build === "all" ? newSources
    : newSources.filter((newSource) => newSource.name === build);


  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");

    // previous build process
    buildSources.forEach(async (source) => {
      const sql = fs
        .readFileSync(`pg/model-transform/${source.fileName}.sql`)
        .toString();
      console.debug("source", source.fileName);
      await pgClient.query(sql);
    });

    // new build process
    
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
