import { exit } from "process";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";
import { buildTargets } from "../../build/parse-build";

(async () => {
  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");

    buildTargets.forEach(async (target) => {
      const sql = fs.readFileSync(`pg/tile-create/${target}.sql`).toString();
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
