import shpjs from "shpjs";
import * as fs from "fs";
import { FeatureCollection } from "geojson";
import * as turf from "@turf/turf";
import { geojsonToWKT } from "@terraformer/wkt";
import { stringify } from "csv-stringify/sync";

(async () => {
  const sources: Array<{ fileName: string; promoteToMulti: boolean }> = [
    {
      fileName: "dcp_city_council_districts",
      promoteToMulti: true,
    },
    {
      fileName: "dcp_community_districts",
      promoteToMulti: true,
    },
    {
      fileName: "cpdb_dcpattributes_poly.shp",
      promoteToMulti: true,
    },
    {
      fileName: "cpdb_dcpattributes_pts.shp",
      promoteToMulti: true,
    },
  ];

  sources.forEach(async (source) => {
    const geogBuffer = fs.readFileSync(`data/download/${source.fileName}.zip`);
    const geojson = (await shpjs(geogBuffer)) as FeatureCollection;
    geojson.features.forEach((feature, index) => {
      if (source.promoteToMulti) {
        if (feature.geometry.type === "Polygon") {
          const mp = turf.multiPolygon(
            [feature.geometry.coordinates],
            feature.properties,
          );
          geojson.features[index] = mp;
        }

        if (feature.geometry.type === "LineString") {
          const mp = turf.multiLineString(
            [feature.geometry.coordinates],
            feature.properties,
          );
          geojson.features[index] = mp;
        }

        if (feature.geometry.type === "Point") {
          const mp = turf.multiPoint(
            [feature.geometry.coordinates],
            feature.properties,
          );
          geojson.features[index] = mp;
        }
      }
    });

    const flatJson = geojson.features.map((feature) => {
      return {
        ...feature.properties,
        wkt: geojsonToWKT(feature.geometry),
      };
    });

    const output = stringify(flatJson, { header: true });

    fs.writeFileSync(`data/convert/${source.fileName}.csv`, output);
  });
})();
