# Documentation

## Components
- S3-compatible storage (Digital Ocean Spaces)
- Data flow runner (GitHub Runner or Local Machine)
- Data flow database (Docker Container within the Runner)
  - Flow
- API database (Docker container on the Local Machine or Digital Ocean Postgres Cluster)
  - API or Target

## Steps

The entire data flow contains 10 steps. They are found in the `scripts` section of the [package.json](../package.json). With some exceptions, they follow the format `<tool used>:<targeted resource>:<operation performed>`. In the [flow steps diagram](./diagrams/flow_steps.drawio.png), they are numbered 0 through 9. They are described in greater detail in the list below.

Steps 1 through 9 can be run with no configuration. They are part of the `flow` command listed in the [README](../README.md#run-the-local-data-flow). Step 0 requires some configuration and is not part of the `flow` command; more context is listed in the step 0 description. Of the remaining steps, they can be run individually using their listed `Command`. This is helpful when a step fails. After fixing the failure, the next steps of the flow can be run without rerunning the steps that already succeeded. In addition to the individual commands, multiple commands can be run together as a `Group`. 

The available groups are `download`, `configure`, `seed`, and `populate`. `download` will retrieve the source files and convert the shapefiles to csvs. `configure` will install dependencies on the flow database. `seed` will initialize the source tables in the flow database and fill them with source data. `populate` will transform the source data within the flow database and then transfer the transformed data to the target database.

0) Pull custom types from target database
   - Command: `drizzle:api:pull`
   - Group: none
   - Description: The API schemas include several custom enum types. These types need to be defined in the data flow database before it can replicate the API schema. Drizzle introspection is performed against the api database, looking only at the custom types. The resulting introspection is saved in the `drizzle/migrations` folder in the `schema.ts` file. There are a few things to note. First, the introspection also produces meta and sql files. However, the data flow does not use these files and they are ignored by source control. Second, Drizzle does not automatically import the `pgEnum` function in the `schema.ts`; any developer that reruns the introspection needs to manually import this method. Third, this step should only need to be run when there are changes to the custom types. Consequently, it is excluded from the `flow` command. Finally, changes to the custom types should happen rarely. When they do happen, they will require updates to the `drizzle/migrations/schema.ts` file. These files will need to be committed an integrated to the `main` branch.

1) Download source files from Digital Ocean Spaces
   - Command: `minio:download`
   - Group: `download`

2) Convert shapefiles into csv files
  - Command: `shp:convert`    
  - Group: `download`

3) Activate PostGIS and other necessary extensions
  - Command: `pg:flow:configure`
  - Group: `configure`

4) Push custom types and enums to the flow database
  - Command: `pg:flow:push`
  - Group: `configure`

5) Create tables in flow database to hold source data
  - Command: `pg:source:create`
  - Group: `seed`

6) Load source tables with source data
  - Command: `pg:source:load`
  - Group: `seed`

7) Create tables in the flow database that model the api database tables
  - Command: `pg:model:create`
  - Group: `seed`

8) Transform the source data and insert it into the model tables
  - Command: `pg:model:transform`
  - Group: `populate`

9) Move the data from the model tables in the flow database to their corresponding target tables in the api database
 - Command: `pg:target:populate`

## Domains
- All
- Admin
- Capital Planning
- Pluto