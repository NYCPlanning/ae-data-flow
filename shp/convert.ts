import shpjs from "shpjs";
import * as fs from "fs";
import { FeatureCollection } from "geojson";
import * as turf from "@turf/turf";

(async () => {
    const geogBuffer = fs.readFileSync("data/download/dcp_city_council_districts.zip");
    const geojson = await shpjs(geogBuffer) as FeatureCollection;
    geojson.features.forEach((feature, index) => {
        if(feature.geometry.type === 'Polygon') {
            if (feature.geometry.coordinates === undefined) {
                console.warn("coordinates were undefined")
            }
            const mp = turf.multiPolygon([feature.geometry.coordinates], feature.properties);
            geojson.features[index] =  mp;
        }
    })
    console.debug("geoj", geojson.features.filter(feature => feature.geometry.type === 'MultiPolygon').length);
})();