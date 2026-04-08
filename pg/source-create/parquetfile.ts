import { DuckDBInstance } from "@duckdb/node-api";
import { exit } from "process";

async function tryduckdb() {
    try {
        const instance = await DuckDBInstance.create(':memory:');
        const connection = await instance.connect();

        const reader = await connection.runAndReadAll(`
          INSTALL spatial;
          LOAD spatial;
          SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet');
          ATTACH 'dbname=data-flow user=postgres host=localhost password=postgres port=8001' AS postgres_db (TYPE postgres);
          INSERT INTO postgres_db.source_school_district SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet')
        `);

        const reader2 = await connection.runAndReadAll(`
            DESCRIBE SELECT * FROM 'data/download/dcp_school_districts.parquet';
        `);

        console.log(reader2.getRows());

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