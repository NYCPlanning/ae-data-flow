import { DuckDBInstance } from "@duckdb/node-api";
import { exit } from "process";

const args = require('minimist')(process.argv.slice(2));
const fileName = args['file'];

async function tryduckdb() {
    const instance = await DuckDBInstance.create(':memory:');
    const connection = await instance.connect();
    try {
        const reader = await connection.runAndReadAll(`
          DESCRIBE SELECT * FROM 'data/download/`+fileName+`';
        `);

        console.log(reader.getRowObjects());

    } catch (e) {
        console.log(e);
    } finally {
        exit();
    }}

tryduckdb();