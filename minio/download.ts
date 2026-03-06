import { Build } from "../build/schemas";
import { minioClient } from "./minio-client";
import { exit } from "process";
import { buildSources } from "../build/parse-build";
import "dotenv/config";

(async () => {
  console.debug("start download");

  type Source = {
    fileName: string;
    fileExtension: "csv" | "zip";
    build: Build;
  } & (
    | {
        bucketName: "edm-publishing";
        bucketSubPath:
          | "db-cpdb/publish/latest"
          | "datasets/dcp_city_council_districts/24B"
          | "datasets/dcp_community_districts/24B"
          | "datasets/dcp_borough_boundary/production"
          | "db-cbbr/publish/latest"
          | "datasets/dcp_nta_2010/24B"
          | "datasets/dcp_nta_2020/24B"
          | "datasets/dcp_census_tracts_2010/23B"
          | "datasets/dcp_census_tracts_2020/25D"
          | "datasets/db-facilities/publish/26v1";
      }
    | {
        bucketName: "ae-data-backups";
        bucketSubPath: "zoning-api";
      }
    | {
        bucketName: "edm-recipes";
        bucketSubPath: "inbox/dcp/dcp_managing_agencies_lookup/20250725";
      }
  );

  const sourcesToDownload: Array<Source> = [
    {
      fileName: "cbbr_options_cascade_v2",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      build: "community-board-budget-requests",
    },
    {
      fileName: "cbbr_options_no_duplicates_surrogate_ids_v2",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      build: "community-board-budget-requests",
    },
    {
      fileName: "cbbr_export",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cbbr/publish/latest",
      build: "community-board-budget-requests",
    },
    {
      fileName: "cpdb_planned_commitments",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      build: "capital-planning",
    },
    {
      fileName: "cpdb_projects",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      build: "capital-planning",
    },
    {
      fileName: "cpdb_dcpattributes_pts.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      build: "capital-planning",
    },
    {
      fileName: "cpdb_dcpattributes_poly.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      build: "capital-planning",
    },
    {
      fileName: "dcp_borough_boundary",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_borough_boundary/production",
      build: "boroughs",
    },
    {
      fileName: "dcp_city_council_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_city_council_districts/24B",
      build: "city-council-districts",
    },
    {
      fileName: "dcp_community_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_community_districts/24B",
      build: "community-districts",
    },
    {
      fileName: "pluto",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      build: "pluto",
    },
    {
      fileName: "zoning_districts",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      build: "pluto",
    },
    {
      fileName: "dcp_managing_agencies_lookup",
      fileExtension: "csv",
      bucketName: "edm-recipes",
      bucketSubPath: "inbox/dcp/dcp_managing_agencies_lookup/20250725",
      build: "agencies",
    },
    {
      fileName: "dcp_nta_2010",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_nta_2010/24B",
      build: "neighborhood-tabulation-areas",
    },
    {
      fileName: "dcp_nta_2020",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_nta_2020/24B",
      build: "neighborhood-tabulation-areas",
    },
    {
      fileName: "dcp_census_tracts_2010",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_census_tracts_2010/23B",
      build: "census-tracts",
    },
    {
      fileName: "dcp_census_tracts_2020",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_census_tracts_2020/25D",
      build: "census-tracts",
    },
    {
      fileName: "source_data_versions",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/db-facilities/publish/26v1",
      build: "data-sources",
    },
  ];

  const downloads: Array<Promise<void>> = [];
  sourcesToDownload.forEach(async (source) => {
    if (buildSources.includes(source.build)) {
      const file = `${source.fileName}.${source.fileExtension}`;
      const filePath = `${source.bucketSubPath}/${file}`;
      downloads.push(
        minioClient.fGetObject(
          source.bucketName,
          filePath,
          `data/download/${file}`,
        ),
      );
    }
  });

  await Promise.all(downloads);
  console.debug("end download");
  exit();
})();
