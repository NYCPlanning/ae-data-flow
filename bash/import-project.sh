export PGPASSWORD=$BUILD_ENGINE_PASSWORD
ogr2ogr -nln project_point Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" cpdb_projects_pts_23adopt -lco precision=NO -lco GEOMETRY_NAME=geom
ogr2ogr -nln project_polygon Pg:"dbname=$BUILD_ENGINE_DB host=$BUILD_ENGINE_HOST user=$BUILD_ENGINE_USER port=$BUILD_ENGINE_PORT" cpdb_projects_poly_23adopt -lco precision=NO -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=geom


