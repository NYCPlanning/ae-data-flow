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
            table: "source_capital_project",
            columns: [
                "ccp_version",
                "m_a_proj_id",
                "m_agency_acro",
                "m_agency" ,
                "m_agency_name" ,
                "description" ,
                "proj_id" ,
                "min_date",
                "max_date",
                "type_category" ,
                "plannedcommit_ccnonexempt" ,
                "plannedcommit_ccexempt" ,
                "plannedcommit_citycost" ,
                "plannedcommit_nccstate" ,
                "plannedcommit_nccfederal" ,
                "plannedcommit_nccother" ,
                "plannedcommit_noncitycost" ,
                "plannedcommit_total" ,
                "adopt_ccnonexempt" ,
                "adopt_ccexempt" ,
                "adopt_citycost" ,
                "adopt_nccstate" ,
                "adopt_nccfederal" ,
                "adopt_nccother" ,
                "adopt_noncitycost" ,
                "adopt_total" ,
                "allocate_ccnonexempt" ,
                "allocate_ccexempt" ,
                "allocate_citycost" ,
                "allocate_nccstate" ,
                "allocate_nccfederal" ,
                "allocate_nccother" ,
                "allocate_noncitycost" ,
                "allocate_total" ,
                "commit_ccnonexempt" ,
                "commit_ccexempt" ,
                "commit_citycost" ,
                "commit_nccstate" ,
                "commit_nccfederal" ,
                "commit_nccother" ,
                "commit_noncitycost" ,
                "commit_total" ,
                "spent_ccnonexempt" ,
                "spent_ccexempt" ,
                "spent_citycost" ,
                "spent_nccstate" ,
                "spent_nccfederal" ,
                "spent_nccother" ,
                "spent_noncitycost" ,
                "spent_total" ,
                "spent_total_checkbooknyc" 
            ],
            filePath: "data/download",
            fileName: "cpdb_projects.csv" 
        },
        {
            table: "source_capital_project_poly",
            columns: [
                "ccpversion",
                "maprojid",
                "magency",
                "magencyacr",
                "projectid",
                "descriptio",
                "typecatego",
                "geomsource",
                "dataname",
                "datasource",
                "datadate",
                "wkt"
            ],
            filePath: "data/convert",
            fileName: "cpdb_dcpattributes_poly.shp.csv"
        },
        {
            table: "source_capital_project_pt",
            columns: [
                "ccpversion",
                "maprojid",
                "magency",
                "magencyacr",
                "projectid",
                "descriptio",
                "typecatego",
                "geomsource",
                "dataname",
                "datasource",
                "datadate",
                "wkt"
            ],
            filePath: "data/convert",
            fileName: "cpdb_dcpattributes_pts.shp.csv"
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
        {
            table: "source_zoning_district",
            columns: ["wkt", "zonedist", "shape_leng", "shape_area"],
            filePath: "data/download",
            fileName: "zoning_districts.csv"
        },
        {
            table: "source_zoning_district_class",
            columns: ["id", "category", "description", "url", "color"],
            filePath: "data",
            fileName: "zoning_district_class.csv"
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
