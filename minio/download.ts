import { Build } from "../schemas";
import { minioClient } from "./minio-client";
import { exit } from "process";
import { buildSchema } from "../schemas";
import "dotenv/config";

(async () => {
  console.debug("start download");
  const build = buildSchema.parse(process.env.BUILD);

  type Source = {
    fileName: string;
    fileExtension: "csv" | "zip";
    builds: Array<Build>;
  } & (
    | {
        bucketName: "edm-publishing";
        bucketSubPath:
          | "db-cpdb/publish/latest"
          | "datasets/dcp_city_council_districts/24B"
          | "datasets/dcp_community_districts/24B"
          | "db-cbbr/publish/FY2025";
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
      builds: ["capital-planning"],
    },
    {
      fileName: "cpdb_projects",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      builds: ["capital-planning"],
    },
    {
      fileName: "cpdb_dcpattributes_pts.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      builds: ["capital-planning"],
    },
    {
      fileName: "cpdb_dcpattributes_poly.shp",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cpdb/publish/latest",
      builds: ["capital-planning"],
    },
    {
      fileName: "dcp_city_council_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_city_council_districts/24B",
      builds: ["admin"],
    },
    {
      fileName: "dcp_community_districts",
      fileExtension: "zip",
      bucketName: "edm-publishing",
      bucketSubPath: "datasets/dcp_community_districts/24B",
      builds: ["admin"],
    },
    {
      fileName: "pluto",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      builds: ["pluto"],
    },
    {
      fileName: "zoning_districts",
      fileExtension: "csv",
      bucketName: "ae-data-backups",
      bucketSubPath: "zoning-api",
      builds: ["pluto"],
    },
    {
      fileName: "cbbr_export",
      fileExtension: "csv",
      bucketName: "edm-publishing",
      bucketSubPath: "db-cbbr/publish/FY2025",
      builds: ["cbbr"],
    },
  ];

  const buildSources =
    build === "all"
      ? sources
      : sources.filter((source) => source.builds.includes(build));

  const downloads = buildSources.map((source) => {
    const file = `${source.fileName}.${source.fileExtension}`;
    const filePath = `${source.bucketSubPath}/${file}`;
    return minioClient.fGetObject(
      source.bucketName,
      filePath,
      `data/download/${file}`,
    );
  });

  await Promise.all(downloads);
  console.debug("end download");
  exit();
})();
