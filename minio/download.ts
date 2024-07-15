import { Build } from "../schemas";
import { minioClient } from "./minio-client";
import { exit } from "process";
import { buildSchema } from "../schemas";

(async () => {
  console.debug("start download");
  const buildInput = process.argv[2];
  const build = buildSchema.optional().parse(buildInput);

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
  ];

  const buildSources =
    build === undefined
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
