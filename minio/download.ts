import { minioClient } from "./minio-client";
import { exit } from "process";

(async () => {
  console.debug("start download");

  type Source = {
    fileName: string;
    fileExtension: "csv" | "zip";
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
  );

  const sources: Array<Source> = [
    {
      fileName: "cpdb_planned_commitments",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
    },
    {
      fileName: "cpdb_projects",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
    },
    {
      fileName: "cpdb_dcpattributes_pts.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
    },
    {
      fileName: "cpdb_dcpattributes_poly.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
    },
    {
      fileName: "dcp_city_council_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_city_council_districts/24B",
    },
    {
      fileName: "dcp_community_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_community_districts/24B",
    },
    {
      fileName: "pluto",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
    },
    {
      fileName: "zoning_districts",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
    },
  ];

  const downloads = sources.map((source) => {
    const file = `${source.fileName}.${source.fileExtension}`;
    const filePath = `${source.bucketSubPath}/${file}`;
    return minioClient.fGetObject(
      source.bucketName,
      filePath,
      `data/download/${file}`,
    );
  });

  await Promise.all(downloads);
  exit();
})();
