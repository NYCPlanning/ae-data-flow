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

These steps are first performed on the `staging` sets of databases. When that process has succeeded and the API's use of it has passed QA, the same process is steps are performed on the `prod` set of databases

### Zoning API example

<a href=https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png><img src="https://github.com/NYCPlanning/ae-data-flow/blob/main/diagrams/workflow_zoning_api_update.drawio.png" width='1000' alt="Diagram of Zoning API data flow">

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
mc alias set spaces $DO_SPACES_ENDPOINT $DO_SPACES_ACCESS_KEY_ID $DO_SPACES_SECRET_ACCESS_KEY
```

We use `spaces` here but you can name the alias anything. When you run `mc config host list` you should see the newly added host with credentials from your `.env`.

### Setup python virtual environment

> [!NOTE]
> These instructions are for use of [pyenv](https://github.com/pyenv/pyenv) to manage python virtual environments. See [these instructions](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation) to install it.
>
> If you are using a different approach like [venv](https://docs.python.org/3/library/venv.html) or [virtualenv](https://virtualenv.pypa.io/en/latest/), follow comparable instructions in the relevant docs.

The `.python-version` file defines which version of python this project uses.

#### Create a virtual environment named `venv_ae_data_flow`

```bash
pyenv virtualenv venv_ae_data_flow
pyenv virtualenvs
```

#### Activate `venv_ae_data_flow` in the current terminal

```bash
pyenv shell venv_ae_data_flow
pyenv version
```

#### Install dependencies

```bash
python3 -m pip install --force-reinstall -r requirements.txt
pip list
dbt deps
```

## Usage
### Quickrun
Once you have set up your `.env` file, you can automatically run all of the below commands in sequence.  To run the commands:
```bash
./import.sh
```
If you receive an error, make sure the script has the correct permissions:
```bash
chmod 755 import.sh
```

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values.

> [!IMPORTANT]
> To use a local database, `sample_local.env` likely has the environment variable values you need.
>
> To use a deployed database in Digital Ocean, the values you need can be found in the AE 1password vault.

To use environment variables defined in `.env`:

```bash
export $(cat .env | sed 's/#.*//g' | xargs)
export BUILD_ENGINE_SERVER=postgresql://${BUILD_ENGINE_USER}:${BUILD_ENGINE_PASSWORD}@${BUILD_ENGINE_HOST}:${BUILD_ENGINE_PORT}
export BUILD_ENGINE_URI=${BUILD_ENGINE_SERVER}/${BUILD_ENGINE_DB}
```

## Local use

> [!NOTE]
> The approaches to running this locally will inform how this will be run in CI using github actions.
>
> This currently requires a local install of `postgres` in order to use the `psql` CLI. We may prefer an approach that does not depend on this.

### Test database connection

```bash
dbt debug
```

### Load source data into data flow DB

Download CSV files from Digital Ocean file storage

```bash
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/pluto.csv pluto.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv
```

Copy CSV files into source data tables

```bash
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/load_sources.sql
```

### Validate source data

```bash
dbt test --select "source:*"
```

### Create API tables in data flow DB

```bash
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file create_tables.sql
```

### Populate API tables in data flow DB

```bash
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file populate_tables.sql
```

### Replace rows in API database tables

```bash
# TODO
# maybe pg_dump + pg_restore?
```
