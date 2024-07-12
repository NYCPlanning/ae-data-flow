import { pgClient } from "./pg-connector";
import * as fs from "fs";
import { exit } from "process";
import format from "pg-format";
import "dotenv/config";

(async () => {
  const targetHost = process.env.TARGET_DATABASE_HOST!;
  const targetPort = process.env.TARGET_DATABASE_PORT!;
  const targetName = process.env.TARGET_DATABASE_NAME!;
  const targetUser = process.env.TARGET_DATABASE_USER!;
  const targetPassword = process.env.TARGET_DATABASE_PASSWORD!;

  try {
    const sql = fs.readFileSync("pg/query/target-wrap.sql").toString();
    const sqlFormat = format(
      sql,
      targetHost,
      targetPort,
      targetName,
      targetUser,
      targetPassword,
    );
    await pgClient.connect();
    await pgClient.query("BEGIN;");
    await pgClient.query(sqlFormat);
    await pgClient.query("COMMIT;");
  } catch (e) {
    await pgClient.query("ROLLBACK;");
    console.error(e);
  } finally {
    await pgClient.end();
    exit();
  }
})();
