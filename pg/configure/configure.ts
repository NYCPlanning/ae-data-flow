import { pgClient } from "../pg-connector";
import * as fs from "fs";
import { exit } from "process";

(async () => {
  const fileName = process.argv[2];
  try {
    const sql = fs.readFileSync(`pg/configure/configure.sql`).toString();
    await pgClient.connect();
    await pgClient.query("BEGIN");
    await pgClient.query(sql);
    await pgClient.query("COMMIT");
  } catch (e) {
    await pgClient.query("ROLLBACK");
    console.error(e);
  } finally {
    await pgClient.end();
    exit();
  }
})();
