# AE Data Flow

This is the primary repository for the data pipelines of the Application Engineering (AE) team at the NYC Department of City Planning (DCP).

These pipelines are used to populate the databases used by our APIs and are called "data flows".

## Local setup

> [!NOTE]
> These instructions depend on docker and docker compose
> If you need to install docker compose, follow [these instructions](https://docs.docker.com/compose/install/).

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values.

### Run the local zoning api database

The `data-flow` steps are run against the `zoning-api` database. Locally, this relies on these two containers running on the same network. The zoning-api creates the `data` network, which the data-flow `db` container can then join.
Before continuing with the `data-flow` setup, follow the steps within `nycplanning/ae-zoning-api` to get its database running in a container on a `data` docker network.

### Run the local data flow

After setting up the zoning-api, return to this repository and run the data-flow 

Build and run the flow database container
```bash
docker compose up --build -d
```

Run the data flow process to populate the zoning api database with data
```bash
BUILD=all npm run flow
```

The "BUILD" environment variable specifies which domain to update. Initial database seeding should use "all".
Subsequent runs may want to only update specific domains. The `BUILD` domain options are: `admin`, `pluto`, and `capital-planning`.

## Documentation

An overview of the data flow design is in the [documentation](documentation/design.md) folder. 
