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
          | "datasets/dcp_community_districts/24B";
      }
    | {
        bucketName: "ae-data-backups";
        bucketSubPath: "zoning-api";
      }
    | {
        bucketName: "edm-recipes";
        bucketSubPath: "inbox/dcp/dcp_managing_agencies_lookup/20250725"
    }
  );

  const sourcesToDownload: Array<Source> = [
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
    }
  ];

  const downloads: Array<Promise<void>> = [];
  sourcesToDownload.forEach(async (source) => {
    if (buildSources.includes(source.build)) {
      const file = `${source.fileName}.${source.fileExtension}`;
      const filePath = `${source.bucketSubPath}/${file}`;
      downloads.push(minioClient.fGetObject(
        source.bucketName,
        filePath,
        `data/download/${file}`,
      ));
    }
  });

  await Promise.all(downloads);
  console.debug("end download");
  exit();
})();
