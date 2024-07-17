# TBD
Design documentation

## Components
- Spaces file storage
- Data flow runner
- Data flow database
- API database

## Steps
### Format
`<tool>:<target>:<operation>`

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
