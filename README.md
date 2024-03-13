# AE Data Flow

This is the primary repository for the data pipelines of Application Engineering team at the NYC Department of City Planning (DCP).

It is used to populate databases used by APIs.

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

The `.python-version` file define which version of python this project uses.

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

### Set environment variables

Create a file called `.env` in the root folder of the project and copy the contents of `sample.env` into that new file.

Next, fill in the blank values and edit `BUILD_ENGINE_SCHEMA=local_YOUR_NAME` to be unique amongst the team.

> [!IMPORTANT]
> To use a local database, `sample_local.env` likely has the environment variable values you need.
>
> To use a deployed database in Digital Ocean, the values you need can be found in the AE 1password vault.

To set those environment variables in a terminal window run `export $(cat .env | sed 's/#.*//g' | xargs)`.

### Test database connection

```bash
dbt debug
```

## Running the project locally

> [!NOTE]
> The approaches to running this locally will inform how this will be run in CI using github actions.

### Load source data

Copy CSV files

```bash
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/pluto.csv pluto.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/zoning_districts.csv zoning_districts.csv
mc cp spaces/${DO_SPACES_BUCKET_DISTRIBUTIONS}/dcp_pluto/23v3/attachments/source_data_versions.csv source_data_versions.csv
```

To create source data tables in the database:

> [!IMPORTANT]
> This assumes `postgres` is installed. We may prefer an approach that does not depend on this assumption.

```bash
export BUILD_ENGINE_SERVER=postgresql://${BUILD_ENGINE_USER}:${BUILD_ENGINE_PASSWORD}@${BUILD_ENGINE_HOST}:${BUILD_ENGINE_PORT}
export BUILD_ENGINE_URI=${BUILD_ENGINE_SERVER}/${BUILD_ENGINE_DB}

psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file sql/load_sources.sql \
  --variable SCHEMA_NAME=${BUILD_ENGINE_SCHEMA}
```

### Validate source data

```bash
dbt test --select "source:*"
```

### Create tables
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file create_tables.sql \
  --variable SCHEMA_NAME=${BUILD_ENGINE_SCHEMA}

### Populate tables
psql ${BUILD_ENGINE_URI} \
  --set ON_ERROR_STOP=1 --single-transaction --quiet \
  --file import_tables.sql \
  --variable SCHEMA_NAME=${BUILD_ENGINE_SCHEMA}

### TBD
