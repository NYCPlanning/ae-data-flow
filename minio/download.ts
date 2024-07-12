import { minioClient } from "./minio-client";
import { exit } from "process";

(async () => {
  console.debug("start download");
  const destinationFolder = "data/download";
  const bucketPublishing = "edm-publishing";
  const publishingFilePaths = [
    "db-cpdb/publish/latest/cpdb_planned_commitments.csv",
    "db-cpdb/publish/latest/cpdb_projects.csv",
    "db-cpdb/publish/latest/cpdb_dcpattributes_pts.shp.zip",
    "db-cpdb/publish/latest/cpdb_dcpattributes_poly.shp.zip",
    "datasets/dcp_city_council_districts/24B/dcp_city_council_districts.zip",
    "datasets/dcp_community_districts/24B/dcp_community_districts.zip",
  ];

  const downloadsPublishing = publishingFilePaths.map((filePath) => {
    const filePathParts = filePath.split("/");
    const fileName = filePathParts[filePathParts.length - 1];
    return minioClient.fGetObject(
      bucketPublishing,
      filePath,
      `${destinationFolder}/${fileName}`,
    );
  });

  const bucketBackups = "ae-data-backups";
  const backupFilePaths = [
    "zoning-api/pluto.csv",
    "zoning-api/zoning_districts.csv",
  ];
  const downloadsBackups = backupFilePaths.map((filePath) => {
    const filePathParts = filePath.split("/");
    const fileName = filePathParts[filePathParts.length - 1];
    return minioClient.fGetObject(
      bucketBackups,
      filePath,
      `${destinationFolder}/${fileName}`,
    );
  });
  await Promise.all([...downloadsPublishing, ...downloadsBackups]);
  exit();
})();
