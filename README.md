# AE Data Flow

This is the primary repository for the data pipelines of the Application Engineering (AE) team at the NYC Department of City Planning (DCP).

These pipelines are used to populate the databases used by our APIs and are called "data flows".

## Documentation

An overview of the data flow design is in the [documentation](documentation/design.md) folder. 

## Local setup

> [!NOTE]
> These instructions depend on docker and docker compose
> If you need to install docker compose, follow [these instructions](https://docs.docker.com/compose/install/).

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values.

**Note:** *Omit `https://` from the spaces endpoint, leaving only the domain itself*

### Install dependencies

The data flow is controlled primarily through node.js modules. Configure these dependencies by:

- Using Node v20: `nvm use`
- Installing node modules: `npm i`

### Run the local zoning api database

The `data-flow` steps are run against the `zoning-api` database. Locally, this relies on these two containers running on the same network. The zoning-api creates the `data` network, which the data-flow `db` container can then join.
Before continuing with the `data-flow` setup, follow the steps within `nycplanning/ae-zoning-api` to get its database running in a container on a `data` docker network.

### Run the local data flow

After setting up the zoning-api, return to this repository and run the data-flow 

Build and run the flow database container
```bash
docker compose up --build -d
```
**Note:** *If you built a previous version of the data flow database, it may be in an incompatible state.*
*To clear this state, run `docker compose down` and run the above "up" command again.*

Run the data flow process to populate the zoning api database with data
```bash
BUILD=all npm run flow
```

The "BUILD" environment variable specifies which domain to update. Initial database seeding should use "all".
Subsequent runs may want to only update specific domains. The `BUILD` domain options are: `boroughs`, `community-districts`, `city-council-districts`, `pluto`, and `capital-planning`.

### Run pieces of the local data flow

The data flow may fail at one of the steps. To pick up the data flow from an intermediate step, reference the [design](/documentation/design.md#steps) to run individual steps or groups of steps. 

If the data flow database is in a confused or irreparable state, it can be wiped using `docker compose down`. 

If the data flow is incomplete but it's necessary to pause and restart later, the database can be paused and saved with `docker compose stop`
