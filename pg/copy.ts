import { exit } from "process";
import * as fs from "fs";
import format from "pg-format";
import {from} from "pg-copy-streams";
import { pipeline } from "stream/promises";
import { pgPool } from "./pg-connector";

(async () => {
    const sources: Array<{table: string, columns: Array<string>, filePath: 'data' | 'data/download', fileName: string}> = [
        { 
            table: "source_borough",
            columns: ["id", "title", "abbr"],
            filePath: "data",
            fileName: "borough.csv"
        },
        {
            table: "source_land_use",
            columns: ["id", "description", "color"],
            filePath: "data",
            fileName: "land_use.csv"
        },
        {
            table: "source_pluto",
            columns: ["wkt", "borough", "block", "lot", "address", "land_use", "bbl"],
            filePath: "data/download",
            fileName: "pluto.csv"
        },
        
    ]

    const sql = fs.readFileSync(`pg/query/source-load.sql`).toString();
    sources.forEach(async ( source ) => {
        const client = await pgPool.connect();
        try{
            const sqlFormat = format(sql, source.table, source.columns);
            const ingestStream = client.query(from(sqlFormat));
            const sourceStream = fs.createReadStream(`${source.filePath}/${source.fileName}`);
            await pipeline(sourceStream, ingestStream);
        } catch (e) {
            console.error(e)
        } finally {
            client.release();
        }
    });
    await pgPool.end();
    exit();
})();
