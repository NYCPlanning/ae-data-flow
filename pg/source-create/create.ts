import { exit } from "process";
import { Build, buildSchema } from "../../schemas";
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
      builds: ["admin", "capital-planning", "pluto"],
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

  const buildSources =
    build === "all"
      ? sources
      : sources.filter((source) => source.builds.includes(build));

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
