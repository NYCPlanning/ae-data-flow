import { DuckDBInstance } from "@duckdb/node-api";
import { exit } from "process";

console.log("hi");
async function tryduckdb() {
    
    try {
        // const credentials = 'dbname=data-flow user=postgres host=localhost'
        const instance = await DuckDBInstance.create(':memory:');
        console.log("hi inside function");
        // const instance = await DuckDBInstance.create('my_duckdb.db');

           // DESCRIBE SELECT * FROM 'dcp_policeprecincts.parquet'
                    //    CREATE TABLE postgres_db.source_police_precinct AS SELECT * FROM 'dcp_policeprecincts.parquet' 
// CREATE TABLE postgres_db.source_police_precinct (precicnt INTEGER, shape_leng DECIMAL(18,11), shape_area DECIMAL(18,11), geometry GEOMETRY);
                //     CREATE TABLE postgres_db.source_police_precinct AS SELECT * FROM read_parquet('dcp_policeprecincts.parquet', schema = MAP {
                //     0: {name: 'precinct', type: 'INTEGER', default_value: null},
                //     1: {name: 'shape_leng', type: 'DECIMAL(18,11)', default_value: null},
                //     2: {name: 'shape_area', type: 'DECIMAL(18,11)', default_value: null},
                //     3: {name: 'geometry', type: 'GEOMETRY', default_value: null}
                //   });

            //      INSTALL spatial;
            // LOAD spatial;
            // ATTACH 'dbname=data-flow user=postgres host=localhost password=postgres port=8001' AS postgres_db (TYPE postgres);
            // DROP TABLE IF EXISTS postgres_db.source_police_precinct;
            // CREATE TABLE postgres_db.source_police_precinct (precicnt text, shape_leng float, shape_area float, geometry GEOMETRY);
            // INSERT INTO postgres_db.source_police_precinct SELECT * FROM read_parquet('dcp_policeprecincts.parquet');
            // SELECT * FROM 'dcp_policeprecincts.parquet';
        const connection = await instance.connect();

        // console.log('connection', connection);
        const reader = await connection.runAndReadAll(`
          SELECT * FROM read_parquet('data/download/dcp_school_districts.parquet') 
        `);

        const columnNames = reader.columnNamesAndTypesJson();
        // console.log(reader.getRows());
        const columnTypes = reader.columnTypes();
        console.log("columnNames", columnNames);
        console.log("column types", columnTypes.toString())

    } catch (e) {
        console.log(e);
    } finally {
        exit();
    }}

tryduckdb();