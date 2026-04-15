import { exit } from "process";
import * as fs from "fs";
import format from "pg-format";
import { from } from "pg-copy-streams";
import { pipeline } from "stream/promises";
import { pgPool } from "../pg-connector";
import { buildSources } from "../../build/parse-build";
import "dotenv/config";
import { Build } from "../../build/schemas";
import { DuckDBInstance } from "@duckdb/node-api";

(async () => {
  type Source = {
    table: string;
    columns: Array<string>;
    filePath: "data" | "data/download" | "data/convert";
    fileName: string;
    build: Build;
    fileType: "csv" | "parquet";
  };
  const sourceTables: Array<Source> = [
    {
      table: "source_agency",
      columns: [
        "agency_code",
        "source",
        "managing_agency_acronym",
        "managing_agency",
      ],
      filePath: "data/download",
      fileName: "dcp_managing_agencies_lookup.csv",
      build: "agencies",
      fileType: "csv",
    },
    {
      table: "source_borough",
      columns: ["boro_code", "boro_name", "shape_leng", "shape_area", "wkt"],
      filePath: "data/convert",
      fileName: "dcp_borough_boundary.csv",
      build: "boroughs",
      fileType: "csv",
    },
    {
      table: "source_city_council_district",
      columns: ["coundist", "shape_leng", "shape_area", "wkt"],
      filePath: "data/convert",
      fileName: "dcp_city_council_districts.csv",
      build: "city-council-districts",
      fileType: "csv",
    },
    {
      table: "source_cbbr_options_no_duplicates",
      columns: [
        "policy_area_id",
        "Policy Area",
        "need_group_id",
        "Need Group",
        "Agency",
        "Type",
        "Need",
        "Request",
      ],
      filePath: "data/download",
      fileName: "cbbr_options_no_duplicates_surrogate_ids_v2.csv",
      build: "community-board-budget-requests",
      fileType: "csv",
    },
    {
      table: "source_cbbr_option",
      columns: [
        "Policy Area",
        "Need Group",
        "Agency",
        "Type",
        "Need",
        "Request",
      ],
      filePath: "data/download",
      fileName: "cbbr_options_cascade_v2.csv",
      build: "community-board-budget-requests",
      fileType: "csv",
    },
    {
      table: "source_cbbr_export",
      columns: [
        "unique_id",
        "tracking_code",
        "borough",
        "borough_code",
        "cd",
        "commdist",
        "cb_label",
        "type_br",
        "priority",
        "policy_area",
        "need_group",
        "need",
        "title",
        "request",
        "explanation",
        "location_specific",
        "site_name",
        "address",
        "street_name",
        "on_street",
        "cross_street_1",
        "cross_street_2",
        "intersection_street_1",
        "intersection_street_2",
        "supporters_1",
        "supporters_2",
        "agency_acronym",
        "agency",
        "agency_category_response",
        "agency_response",
        "geo_function",
        "geom",
      ],
      filePath: "data/download",
      fileName: "cbbr_export.csv",
      build: "community-board-budget-requests",
      fileType: "csv",
    },
    {
      table: "source_community_district",
      columns: ["borocd", "shape_leng", "shape_area", "wkt"],
      filePath: "data/convert",
      fileName: "dcp_community_districts.csv",
      build: "community-districts",
      fileType: "csv",
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
        "plannedcommit_total",
      ],
      filePath: "data/download",
      fileName: "cpdb_planned_commitments.csv",
      build: "capital-planning",
      fileType: "csv",
    },
    {
      table: "source_capital_project",
      columns: [
        "ccp_version",
        "m_a_proj_id",
        "m_agency_acro",
        "m_agency",
        "m_agency_name",
        "description",
        "proj_id",
        "min_date",
        "max_date",
        "type_category",
        "plannedcommit_ccnonexempt",
        "plannedcommit_ccexempt",
        "plannedcommit_citycost",
        "plannedcommit_nccstate",
        "plannedcommit_nccfederal",
        "plannedcommit_nccother",
        "plannedcommit_noncitycost",
        "plannedcommit_total",
        "adopt_ccnonexempt",
        "adopt_ccexempt",
        "adopt_citycost",
        "adopt_nccstate",
        "adopt_nccfederal",
        "adopt_nccother",
        "adopt_noncitycost",
        "adopt_total",
        "allocate_ccnonexempt",
        "allocate_ccexempt",
        "allocate_citycost",
        "allocate_nccstate",
        "allocate_nccfederal",
        "allocate_nccother",
        "allocate_noncitycost",
        "allocate_total",
        "commit_ccnonexempt",
        "commit_ccexempt",
        "commit_citycost",
        "commit_nccstate",
        "commit_nccfederal",
        "commit_nccother",
        "commit_noncitycost",
        "commit_total",
        "spent_ccnonexempt",
        "spent_ccexempt",
        "spent_citycost",
        "spent_nccstate",
        "spent_nccfederal",
        "spent_nccother",
        "spent_noncitycost",
        "spent_total",
        "spent_total_checkbooknyc",
      ],
      filePath: "data/download",
      fileName: "cpdb_projects.csv",
      build: "capital-planning",
      fileType: "csv",
    },
    {
      table: "source_capital_project_m_poly",
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
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "cpdb_dcpattributes_poly.shp.csv",
      build: "capital-planning",
      fileType: "csv",
    },
    {
      table: "source_capital_project_m_pnt",
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
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "cpdb_dcpattributes_pts.shp.csv",
      build: "capital-planning",
      fileType: "csv",
    },
    {
      table: "source_land_use",
      columns: ["id", "description", "color"],
      filePath: "data",
      fileName: "land_use.csv",
      build: "pluto",
      fileType: "csv",
    },
    {
      table: "source_pluto",
      columns: ["wkt", "borough", "block", "lot", "address", "land_use", "bbl"],
      filePath: "data/download",
      fileName: "pluto.csv",
      build: "pluto",
      fileType: "csv",
    },
    {
      table: "source_zoning_district",
      columns: ["wkt", "zonedist", "shape_leng", "shape_area"],
      filePath: "data/download",
      fileName: "zoning_districts.csv",
      build: "pluto",
      fileType: "csv",
    },
    {
      table: "source_zoning_district_class",
      columns: ["id", "category", "description", "url", "color"],
      filePath: "data",
      fileName: "zoning_district_class.csv",
      build: "pluto",
      fileType: "csv",
    },
    {
      table: "source_neighborhood_tabulation_area_2010",
      columns: [
        "borough_code",
        "borough_name",
        "county_fips",
        "nta_code",
        "nta_name",
        "shape_leng",
        "shape_area",
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "dcp_nta_2010.csv",
      build: "neighborhood-tabulation-areas",
      fileType: "csv",
    },
    {
      table: "source_neighborhood_tabulation_area_2020",
      columns: [
        "borough_code",
        "borough_name",
        "county_fips",
        "nta_2020",
        "nta_name",
        "nta_abbrev",
        "nta_type",
        "cdta_2020",
        "cdta_name",
        "shape_leng",
        "shape_area",
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "dcp_nta_2020.csv",
      build: "neighborhood-tabulation-areas",
      fileType: "csv",
    },
    {
      table: "source_census_tracts_2010",
      columns: [
        "census_tract_label",
        "borough_code",
        "borough_name",
        "census_tract_2010",
        "borough_code_census_tract_2010",
        "community_development_eligible",
        "nta_code",
        "nta_name",
        "puma",
        "shape_leng",
        "shape_area",
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "dcp_census_tracts_2010.csv",
      build: "census-tracts",
      fileType: "csv",
    },
    {
      table: "source_census_tracts_2020",
      columns: [
        "census_tract_label",
        "borough_code",
        "borough_name",
        "census_tract_2020",
        "borough_code_census_tract_2020",
        "community_development_eligible",
        "nta_name",
        "nta_2020",
        "cdta_2020",
        "cdta_name",
        "geo_id",
        "puma",
        "shape_leng",
        "shape_area",
        "wkt",
      ],
      filePath: "data/convert",
      fileName: "dcp_census_tracts_2020.csv",
      build: "census-tracts",
      fileType: "csv",
    },
    {
      table: "source_facility",
      columns: [
        "FACNAME",
        "ADDRESSNUM",
        "STREETNAME",
        "ADDRESS",
        "CITY",
        "ZIPCODE",
        "FACTYPE",
        "FACSUBGRP",
        "FACGROUP",
        "FACDOMAIN",
        "SERVAREA",
        "OPNAME",
        "OPABBREV",
        "OPTYPE",
        "OVERAGENCY",
        "OVERABBREV",
        "OVERLEVEL",
        "CAPACITY",
        "CAPTYPE",
        "BORO",
        "BIN",
        "BBL",
        "LATITUDE",
        "LONGITUDE",
        "XCOORD",
        "YCOORD",
        "CD",
        "NTA2010",
        "NTA2020",
        "COUNCIL",
        "CT2010",
        "CT2020",
        "BOROCODE",
        "SCHOOLDIST",
        "POLICEPRCT",
        "DATASOURCE",
        "UID",
      ],
      filePath: "data/download",
      fileName: "facilities.csv",
      build: "facilities",
      fileType: "csv",
    },
    {
      table: "source_school_district",
      columns: [
        "schooldist",
        "shape_leng",
        "shape_area",
        "geometry"
      ],
      filePath: "data/download",
      fileName: "dcp_school_districts.parquet",
      build: "school-districts",
      fileType: "parquet",
    },
  ];

  const sqlTemplate = fs.readFileSync(`pg/source-load/load.sql`).toString();

  const copy = async (source: Source) => {
    const instance = await DuckDBInstance.create(':memory:');
    const connection = await instance.connect();
    if (source.fileType === "parquet") {
      try {
        await connection.run(`
        CREATE SECRET postgres_secret (
        TYPE postgres,
        HOST $host,
        PORT $port,
        DATABASE $database,
        USER $user,
        PASSWORD $password
        );`, {
          'host': process.env.FLOW_DATABASE_HOST || '',
          'port': process.env.FLOW_DATABASE_PORT || '',
          'database': process.env.FLOW_DATABASE_NAME || '',
          'user': process.env.FLOW_DATABASE_USER || '',
          'password': process.env.FLOW_DATABASE_PASSWORD || ''
        }
        );

        await connection.run(`
        ATTACH '' AS postgres_db (TYPE postgres, SECRET postgres_secret);
        `);

        const copy = `COPY postgres_db.` + source.table + ` FROM '` + source.filePath + `/` + source.fileName + `' (FORMAT parquet);`
        await connection.run(copy);
      } catch (e) {
        console.error(e);
      } finally {
        connection.disconnectSync();
      }
    } else {
      const client = await pgPool.connect();
      try {
        const sqlFormat = format(sqlTemplate, source.table, source.columns);

        const ingestStream = client.query(from(sqlFormat));

        const sourceStream = fs.createReadStream(
          `${source.filePath}/${source.fileName}`,
        );
        console.debug("source", source.fileName);
        await pipeline(sourceStream, ingestStream);

      } catch (e) {
        console.error(e);
      } finally {
        client.release();
      }
    }
  };

  const copies: Array<Promise<void>> = [];
  buildSources.forEach((buildSource) => {
    sourceTables.forEach((sourceTable) => {
      if (sourceTable.build === buildSource) {
        copies.push(copy(sourceTable));
      }
    });
  });
  await Promise.all(copies);
  await pgPool.end();
  exit();
})();
