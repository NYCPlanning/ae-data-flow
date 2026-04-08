import { DuckDBInstance } from "@duckdb/node-api";
import { exit } from "process";

async function tryduckdb() {
    try {
        const instance = await DuckDBInstance.create(':memory:');
        const connection = await instance.connect();

        const reader = await connection.runAndReadAll(`
          INSTALL spatial;
          LOAD spatial;
          SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet') 
        `);

        const columnTypes = reader.columnTypes();
        const columnNames = reader.columnNames();

        console.log("column names", columnNames);
        console.log("column types", columnTypes.toString())

    } catch (e) {
        console.log(e);
    } finally {
        exit();
    }}

tryduckdb();