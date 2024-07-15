import { exit } from "process";
import { Build, buildSchema } from "../../schemas";
import { pgClient } from "../pg-connector";
import * as fs from "fs";

(async () => {
  const build = buildSchema.optional().parse(process.argv[2]);

  type Source = {
    fileName: string;
    treeDepth: number;
    builds: Array<Build>;
  };

  const sources: Array<Source> = [
    {
      fileName: "borough",
      treeDepth: 0,
      builds: ["admin", "capital-planning", "pluto"],
    },
    {
      fileName: "admin",
      treeDepth: 1,
      builds: ["admin"],
    },
    {
      fileName: "capital-planning",
      treeDepth: 1,
      builds: ["capital-planning"],
    },
    {
      fileName: "pluto",
      treeDepth: 1,
      builds: ["pluto"],
    },
  ];

  const buildSources =
    build === undefined
      ? sources
      : sources.filter((source) => source.builds.includes(build));
  buildSources.sort((a, b) => a.treeDepth - b.treeDepth);

  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");
    buildSources.forEach(async (source) => {
      const sql = fs
        .readFileSync(`pg/model-transform/${source.fileName}.sql`)
        .toString();
      console.debug("source", source.fileName);
      await pgClient.query(sql);
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
