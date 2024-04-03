# AE Data Flow

This is the primary repository for the data pipelines of the Application Engineering (AE) team at the NYC Department of City Planning (DCP).

These pipelines are used to populate the databases used by our APIs and are called "data flows".

## Design

For all AE data flows, there is one database cluster with a `staging` and a `prod` database. There are also `dev` databases. These are called data flow databases.

For each API, there is a database cluster with a `staging` and a `prod` database. The only tables in those databases are those that an API uses. These are called API databases.

For each API and the relevant databases, this is the approach to updating data:

1. Load source data into the data flow database
2. Create tables that are identical in structure to the API database tables
3. Replace the rows in the API database tables

These steps are first performed on the `staging` sets of databases. When that process has succeeded and the API's use of it has passed QA, the same process is performed on the `prod` set of databases.

This is a more granular description of those steps:

1. Download CSV files from Digital Ocean file storage
2. Copy CSV files into source data tables
3. Test source data tables
4. Create API tables in the data flow database
5. Populate the API tables in data flow database
6. Replace rows in API tables in the API database

### Zoning API example

<a href=https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png><img src="https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png" width='1000' alt="Diagram of Zoning API data flow">

## CI usage

We use a github action to perform API database updates.

We have three [environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) to configure the databases and credentials used for an API database update.

The `dev` environment can used on any branch. The `staging` and `production` environments can only be used on the `main` branch.

When an action attempts to use the `production` environment, specific people or teams specified in this repo's settings must approve the action run's access of environment.

## Local setup

### Setup MiniO for S3 file transfers

> [!NOTE]
> These instructions are for local setup on macOS.

For non-public files like our CSVs in `/edm/distribution/`, we can use [minio](https://github.com/minio/minio) for authenticated file transfers.

#### Install

```bash
brew install minio/stable/mc
```

#### Add DO Spaces to the `mc` configuration

```bash
mc alias set spaces $DO_SPACES_ENDPOINT $DO_SPACES_ACCESS_KEY $DO_SPACES_SECRET_KEY
```

We use `spaces` here but you can name the alias anything. When you run `mc config host list` you should see the newly added host with credentials from your `.env`.

### Setup python virtual environment

> [!NOTE]
> These instructions are for use of [pyenv](https://github.com/pyenv/pyenv) to manage python virtual environments. See [these instructions](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation) to install it.
>
> If you are using a different approach like [venv](https://docs.python.org/3/library/venv.html) or [virtualenv](https://virtualenv.pypa.io/en/latest/), follow comparable instructions in the relevant docs.

The `.python-version` file defines which version of python this project uses.

#### Install

```bash
brew install pyenv
brew install pyenv-virtualenv
```

#### Create a virtual environment named `venv_ae_data_flow`

```bash
pyenv virtualenv venv_ae_data_flow
pyenv virtualenvs
```

#### Activate `venv_ae_data_flow` in the current terminal

```bash
pyenv activate venv_ae_data_flow
pyenv version
```

#### Install dependencies

```bash
python3 -m pip install --force-reinstall -r requirements.txt
pip list
dbt deps
```

### Setup postgres

We use `postgres` version 15 in order to use the `psql` CLI.

```bash
brew install postgresql@15
# Restart the terminal
psql --version
```

## Local usage

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values.

> [!IMPORTANT]
> To use a local database, `sample_local.env` likely has the environment variable values you need.
>
> To use a deployed database in Digital Ocean, the values you need can be found in the AE 1password vault.

### Run local database with docker compose

Next, use [docker compose](https://docs.docker.com/compose/) to stand up a local PostGIS database.

```bash
docker compose up
```

If you need to install docker compose, follow [these instructions](https://docs.docker.com/compose/install/).

### Run each step

```bash
./bash/download.sh
./bash/import.sh
./bash/transform.sh
./bash/export.sh
./bash/update_api_db.sh
```

If you receive an error, make sure the script has the correct permissions:

```bash
chmod 755 import.sh
```

## Setup with docker
```bash
docker compose run -it data-flow bash
```