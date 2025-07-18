import { exit } from "process";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";
import { buildSources } from "../../build/parse-build";

(async () => {
  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");

    buildSources.forEach(async (source) => {
      const sql = fs.readFileSync(`pg/source-create/${source}.sql`).toString();
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
