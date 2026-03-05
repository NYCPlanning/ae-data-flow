import { exit } from "process";
import { DuckDBInstance } from "@duckdb/node-api";
import { pgClient } from "../pg-connector";
import * as fs from "fs";
import "dotenv/config";
import { buildSources } from "../../build/parse-build";

(async () => {
  try {
    await pgClient.connect();
    await pgClient.query("BEGIN;");

    const instance = await DuckDBInstance.create(':memory:');
    const connection = await instance.connect();

    buildSources.forEach(async (source) => {
      const sql = fs.readFileSync(`pg/source-create/${source}.sql`).toString();
      await pgClient.query(sql);

      const duckdbSql = fs.readFileSync(`pg/source-create/parquet/${source}.sql`).toString(); 
      console.log(duckdbSql);
      await connection.runAndReadAll(duckdbSql);
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
