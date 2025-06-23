import shpjs from "shpjs";
import * as fs from "fs";
import { FeatureCollection } from "geojson";
import * as turf from "@turf/turf";
import { geojsonToWKT } from "@terraformer/wkt";
import { stringify } from "csv-stringify/sync";
import { exit } from "process";
import { Build, buildSources } from "../schemas";
import "dotenv/config";

(async () => {
  console.debug("convert csvs to shapefiles");

  type Source = {
    fileName: string;
    build: Build;
    promoteToMulti: boolean;
  };
  const sources: Array<Source> = [
    {
      fileName: "dcp_city_council_districts",
      build: "city-council-districts",
      promoteToMulti: true,
    },
    {
      fileName: "dcp_community_districts",
      build: "community-districts",
      promoteToMulti: true,
    },
    {
      fileName: "cpdb_dcpattributes_poly.shp",
      build: "capital-planning",
      promoteToMulti: true,
    },
    {
      fileName: "cpdb_dcpattributes_pts.shp",
      build: "capital-planning",
      promoteToMulti: true,
    },
  ];

  const conversion = async (source: Source) => {
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
  };
  const conversions: Array<Promise<void>> = [];
  buildSources.forEach(async (buildSource) => {
    sources.forEach((source) => {
      if (source.build === buildSource) {
        conversions.push(conversion(source)); 
      }
    })
  }); 
  
  await Promise.all(conversions);
  exit();
})();
