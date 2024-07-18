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

The entire data flow contains 10 steps. They are found in the `scripts` section of the [package.json](../package.json). With some exceptions, they follow the format `<tool used>:<targeted resource>:<operation performed>`. In the [flow steps diagram](./diagrams/flow_steps.drawio.png), they are numbered 0 through 9. They are described in greater detail in the list below.

Steps 1 through 9 can be run with no configuration. They are part of the `flow` command listed in the [README](../README.md#run-the-local-data-flow). Step 0 requires some configuration and is not part of the `flow` command; more context is listed in the step 0 description. Of the remaining steps, they can be run individually using their listed `Command`. This is helpful when a step fails. After fixing the failure, the next steps of the flow can be run without rerunning the steps that already succeeded. In addition to the individual commands, multiple commands can be run together as a `Group`. 

The available groups are `download`, `configure`, `seed`, and `populate`. `download` will retrieve the source files and convert the shapefiles to csvs. `configure` will install dependencies on the flow database. `seed` will initialize the source tables in the flow database and fill them with source data. `populate` will transform the source data within the flow database and then transfer the transformed data to the target database.

0) Pull custom types from target database
   - Command: `drizzle:api:pull`
   - Group: none
   - Tool: Drizzle
   - Run from: Runner, [drizzle (api config)](../drizzle/api.config.ts)
   - Run against: API database
   - Description: The API schemas include several custom enum types. These types need to be defined in the data flow database before it can replicate the API schema. Drizzle introspection is performed against the api database, looking only at the custom types. The resulting introspection is saved in the `drizzle/migrations` folder in the `schema.ts` file. There are a few things to note. First, the introspection also produces meta and sql files. However, the data flow does not use these files and they are ignored by source control. Second, Drizzle does not automatically import the `pgEnum` function in the `schema.ts`; any developer that reruns the introspection needs to manually import this method. Third, this step should only need to be run when there are changes to the custom types. Consequently, it is excluded from the `flow` command. Finally, changes to the custom types should happen rarely. When they do happen, they will require updates to the [drizzle/migration/schema.ts](../drizzle/migration/schema.ts) file. These files will need to be committed an integrated to the `main` branch.

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

4) Push custom types and enums to the flow database
  - Command: `drizzle:flow:push`
  - Group: `configure`
  - Tool: drizzle
  - Run from: Data flow runner, [drizzle (flow config)](../drizzle/flow.config.ts)
  - Run against: Flow database
  - Description: Push the enums stored in [drizzle/migration/]

5) Create tables in flow database to hold source data
  - Command: `pg:source:create`
  - Group: `seed`
  - Tool: pg.js [pg/source-create](../pg/source-create/create.ts)
  - Run from: Data flow runner
  - Run against: Flow database
  - Description: Run sql commands to [create tables](../pg/source-create/borough.sql) that hold data as they are stored in their source files.

6) Load source tables with source data
  - Command: `pg:source:load`
  - Group: `seed`
  - Tool: pg.js [pg/source-load](../pg/source-load/load.ts)
  - Run from: Data flow runner
  - Run against: Flow database

7) Create tables in the flow database that model the api database tables
  - Command: `db:pg:model:create`
  - Group: `seed`
  - Tool: pg_dump and psql, [db/pg/model-create](../db/pg/model-create/all.sh)
  - Run from: Flow database
  - Run against: Flow database

8) Transform the source data and insert it into the model tables
  - Command: `pg:model:transform`
  - Group: `populate`
  - Tool: pg.js, [pg/model-transform](../pg/model-transform/transform.ts)
  - Run from: Data flow runner
  - Run against: Flow database

9) Move the data from the model tables in the flow database to their corresponding target tables in the api database
 - Command: `db:pg:target:populate`
 - Group: `populate`
 - Tool: psql, [db/pg/target-populate](../db/pg/target-populate/populate.sh)
- Run from: Flow database
- Run against: API database

## Domains

The data flow can be used to either initialize a full data suite or update a portion of the full suite. These portions are group into "Domains". The data flow is divided into four Domains- "all", "admin", "capital-planning", and "pluto". They are visualized in the [domains diagram](./diagrams/domains.drawio.png).  

The "all" domain contains every other domain plus "Boroughs". The "admin" domain contains administrative boundaries, other than Boroughs. Boroughs are excluded from the "admin" domain because tax lots depend on the Borough Ids existing. Rebuilding Boroughs would require also require rebuilding tax lots.

The "capital-planning" domain applies to tables derived from the capital planning database. The "pluto" domain applies to tables derived from the "pluto" dataset.

A domain must be specified with a `BUILD` environment variable when running the data-flow
