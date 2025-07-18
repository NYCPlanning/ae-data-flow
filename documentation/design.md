# Documentation

## Components
The data flow coordinates data across a few resource. These resource are:

- S3-compatible storage (Digital Ocean Spaces)
  - Data are managed mostly by the Data Engineering team. Though, the Application Engineering team manages a few of its own resources.
- Data flow runner (GitHub Runner or Local Machine)
  - The data flow is coordinated from this service. During development, it is run on a developer's machine. In staging and production, it is a GitHub Action Runner.
- Data flow database (Docker Container within the Runner)
  - The Data flow runner (both the GitHub Action and Local Machine) version contains a Database within a Docker container.
  - It is referred to as the "Flow" database
- API database (Docker container on the Local Machine or Digital Ocean Postgres Cluster)
  - This the database that actually serves the data to applications. Locally, it exists within a Docker container. In live environments, it exists on a Digital Ocean Postgres cluster. There are two steps which are run from the "Flow" database against the "API" database. When running locally, these database communicate via a docker network. When run against the Digital Ocean cluster, it runs through the internet.
  - It is referred to as the "API" or "Target" database
## Steps

The entire data flow contains 8 steps. They are found in the `scripts` section of the [package.json](../package.json). With some exceptions, they follow the format `<tool used>:<targeted resource>:<operation performed>`. In the [flow steps diagram](./diagrams/flow_steps.drawio.png), they are numbered 1 through 8. They are described in greater detail in the list below.

These steps are part of the `flow` command listed in the [README](../README.md#run-the-local-data-flow).They can be run individually using their listed `Command`. This is helpful when a step fails. After fixing the failure, the next steps of the flow can be run without rerunning the steps that already succeeded. In addition to the individual commands, multiple commands can be run together as a `Group`.

The available groups are `download`, `configure`, `seed`, and `populate`. `download` will retrieve the source files and convert the shapefiles to csvs. `configure` will install dependencies on the flow database. `seed` will initialize the source tables in the flow database and fill them with source data. `populate` will transform the source data within the flow database and then transfer the transformed data to the target database.

1) Download source files from Digital Ocean Spaces
   - Command: `minio:download`
   - Group: `download`
   - Tool: minio.js
   - Run from: Data flow runner, [minio/download.ts](../minio/download.ts)
   - Run against: S3 storage
   - Description: Use the minio node module to download source files from Digital Ocean. Files are saved on the Data flow runner in the [data/download](../data/download/) folder.

2) Convert shapefiles into csv files
   - Command: `shp:convert`
   - Group: `download`
   - Tool: shapefile.js
   - Run from: Data flow runner, [shp/convert.ts](../shp/convert.ts)
   - Run against: Data flow runner
   - Description: Several source files are stored as shapefiles. However, the database copy functions better handle csv files. In this step, we use the shapefile node module to convert the shapefiles to csvs. The resulting files are stored in [data/convert](../data/convert/)

3) Activate PostGIS and other necessary extensions
   - Command: `pg:flow:configure`
   - Group: `configure`
   - Tool: pg.js
   - Run from: Data flow runner, [pg/configure](../pg/configure/configure.ts)
   - Run against: Data flow database
   - Description: Run a sql command against the data flow database to [activate PostGIS](../pg/configure/configure.sql)

4) Create tables in flow database to hold source data
   - Command: `pg:source:create`
   - Group: `seed`
   - Tool: pg.js [pg/source-create](../pg/source-create/create.ts)
   - Run from: Data flow runner
   - Run against: Flow database
   - Description: Run sql commands to [create tables](../pg/source-create/borough.sql) that hold data as they are stored in their source files. The source tables also create constraints that will check data validity as it is copied into the source tables.
   If any source tables already existed, drop them before adding them again.

5) Load source tables with source data
   - Command: `pg:source:load`
   - Group: `seed`
   - Tool: pg.js [pg/source-load](../pg/source-load/load.ts)
   - Run from: Data flow runner
   - Run against: Flow database
   - Description: Copy the source data from the `data` folder to the source tables within the flow database.

6) Create tables in the flow database that model the api database tables
   - Command: `db:pg:model:create`
   - Group: `seed`
   - Tool: pg_dump and psql, [db/pg/model-create](../db/pg/model-create/all.sh)
   - Run from: Flow database
   - Run against: Flow database
   - Description: Run `pg_dump` and `psql` from the flow database docker container.
   Use `pg_dump` to extract the API Table Schemas into a `sql` file stored in the flow database docker container.
   Use `psql` to read the `sql` file of the dump into the flow database.
   If any model tables already existed in the flow database, drop them before adding them again.

7) Transform the source data and insert it into the model tables
   - Command: `pg:model:transform`
   - Group: `populate`
   - Tool: pg.js, [pg/model-transform](../pg/model-transform/transform.ts)
   - Run from: Data flow runner
   - Run against: Flow database
   - Description: Use pg node to run the [`sql` files](../pg/model-transform/capital-planning.sql) that transform the `source` columns into their respective `model` columns. Export the populated `model` tables to `.csv` files within the flow database docker container. Truncate any data that may already exist in the `model` tables before inserting the data again.

8) Move the data from the model tables in the flow database to their corresponding target tables in the api database
   - Command: `db:pg:target:populate`
   - Group: `populate`
   - Tool: psql, [db/pg/target-populate](../db/pg/target-populate/populate.sh)
   - Run from: Flow database
   - Run against: API database
   - Description: Use `psql` to truncate the target tables in the api database and then copy data from the `csv` files into the target tables. Perform the truncation and copy as a single transaction, allowing it to ROLLBACK under failures.

## Domains

The data flow can be used to either initialize a full data suite or update a portion of the full suite. These portions are group into "Domains". The data flow is divided into the following Domains: "all", "agencies", "boroughs", "community-board-budget-requests", "community-districts", "city-council-districts", "capital-planning", and "pluto". They are visualized in the [domains diagram](./diagrams/build_table_relationship.drawio.png).

The domains pertain to a set of tables that are derived from a database or dataset. Domains may have other domains as dependencies (in which they generate tables that are needed for the current domain) and/or dependents (in which the  current domain's tables impact tables in anotehr domain). These are defined as parent/child arrays in the [schema](../build/schemas.ts).

The "capital-planning" and "pluto" domains apply to tables derived from the capital planning database and pluto dataset respectively. The "boroughs" and "agencies" domains are responsible for the borough and agency tables respectively. The "community-districts" and "city-council-districts" domains are responsible for those respective administrative boundaries. The "all" domain contains every other domain.

A domain must be specified with a `BUILD` environment variable when running the data-flow
