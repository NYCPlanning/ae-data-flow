# AE Data Flow

This is the primary repository for the data pipelines of the Application Engineering (AE) team at the NYC Department of City Planning (DCP).

These pipelines are used to populate the databases used by our APIs and are called "data flows".

## Design
For all AE data flows, there is an ephemeral database within a docker-ized runner

For each API, there is a database cluster with a `data-qa` and a `prod` database. The only tables in those databases are those that an API uses. These are called API databases.

For each API and the relevant databases, this is the approach to updating data:

1. Load source data into the data flow ephemeral database
2. Create tables that are identical in structure to the API database tables
3. Replace the rows in the API database tables

The exact data flow steps are refined while working in a `local` docker environment. After the steps are stable, they are merged into `main`. From there, they are run first against a `data-qa` API database from within the `data-flow` GitHub action. After receiving quality checks, the `data-flow` GitHub Action is targeted against the `prod` API database.

This is a more granular description of those steps:
1. Download CSV files from Digital Ocean file storage
2. Copy CSV files into source data tables
3. Test source data tables
4. Create API tables in the data flow ephemeral database
5. Populate the API tables in data flow database
6. Replace rows in API tables in the API database

### Infrastructure

<a href=https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/infrastructure_api_data_flow.drawio.drawio.png><img src="https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/infrastructure_api_data_flow.drawio.drawio.png" width='1000' alt="Diagram of API data flow infrastructure">

### Zoning API example

<a href=https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png><img src="https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png" width='1000' alt="Diagram of Zoning API data flow">

## CI usage

We use a github action to perform API database updates.

We have three [environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) to configure the databases and credentials used for an API database update.

The `dev` environment can used on any branch. The `data-qa` and `production` environments can only be used on the `main` branch.

When an action attempts to use the `production` environment, specific people or teams specified in this repo's settings must approve the action run's access of environment.

## Local setup

> [!NOTE]
> These instructions depend on docker and docker compose 
> If you need to install docker compose, follow [these instructions](https://docs.docker.com/compose/install/).

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values.

### Run the local zoning api database
The `data-flow` steps are run against the `zoning-api` database. Locally, this relies on these two containers running on the same network. The zoning-api creates the network, which the data-flow then joins.
Before continuing with the `data-flow` setup, follow the steps within `nycplanning/ae-zoning-api` to get its database running in a container.

### Run data-flow local database with docker compose

```bash
./bash/utils/setup_local_db.sh
```

### Run each step to complete the data flow

```bash
docker compose exec data-flow bash ./bash/download.sh
docker compose exec data-flow bash ./bash/activate_postgis.sh
docker compose exec data-flow bash ./bash/import.sh
docker compose exec data-flow bash ./bash/transform.sh
docker compose exec data-flow bash ./bash/export.sh
docker compose exec data-flow bash ./bash/update_api_db.sh
```

If you receive an error, make sure the script has the correct permissions:

```bash
chmod 755 import.sh
```
