import { exit } from "process";
import { buildSources } from "../../build/parse-build";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";

(async () => {
  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");

    buildSources.forEach(async (source) => {
      const sql = fs
        .readFileSync(`pg/model-transform/${source}.sql`)
        .toString();
      console.debug("source", source);
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
