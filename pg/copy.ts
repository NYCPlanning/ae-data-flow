import { exit } from "process";
import * as fs from "fs";
import format from "pg-format";
import {from} from "pg-copy-streams";
import { pipeline } from "stream/promises";
import { pgPool } from "./pg-connector";

(async () => {
    const sources: Array<{table: string, columns: Array<string>, filePath: 'data' | 'data/download' | 'data/convert', fileName: string}> = [
        { 
            table: "source_borough",
            columns: ["id", "title", "abbr"],
            filePath: "data",
            fileName: "borough.csv"
        },
        {
            table: "source_city_council_district",
            columns: ["coundist", "shape_leng", "shape_area", "wkt"],
            filePath: "data/convert",
            fileName: "dcp_city_council_districts.csv"
        },
        {
            table: "source_capital_commitment",
            columns: [
                "ccp_version",
                "m_agency",
                "project_id",
                "m_a_proj_id",
                "budget_line",
                "project_type",
                "s_agency_acro",
                "s_agency_name",
                "plan_comm_date",
                "project_description",
                "commitment_description",
                "commitment_code",
                "typ_c",
                "typ_c_name",
                "plannedcommit_ccnonexempt",
                "plannedcommit_ccexempt",
                "plannedcommit_citycost",
                "plannedcommit_nccstate",
                "plannedcommit_nccfederal",
                "plannedcommit_nccother",
                "plannedcommit_noncitycost",
                "plannedcommit_total"
            ],
            filePath: "data/download",
            fileName: "cpdb_planned_commitments.csv"
        },
        {
            table: "source_land_use",
            columns: ["id", "description", "color"],
            filePath: "data",
            fileName: "land_use.csv"
        },
        // {
        //     table: "source_pluto",
        //     columns: ["wkt", "borough", "block", "lot", "address", "land_use", "bbl"],
        //     filePath: "data/download",
        //     fileName: "pluto.csv"
        // },
        {
            table: "source_zoning_district",
            columns: ["wkt", "zonedist", "shape_leng", "shape_area"],
            filePath: "data/download",
            fileName: "zoning_districts.csv"
        }
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
