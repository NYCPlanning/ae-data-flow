# AE Data Flow

This is the primary repository for the data pipelines of Application Engineering team at the NYC Department of City Planning (DCP).

It is used to populate databases used by APIs.

## Local setup

### Make sure you're using the correct version of Node

The `.nvmrc` file tells you which version of node you should be using to run the project.

If you're using [nvm](https://github.com/nvm-sh/nvm) and already have the correct version installed, you can switch by running `nvm use` from the root of this repo.

### Make sure you're using the correct version of python

The `.python-version` file tells you which version of python you should be using to run the project.

If you're using [pyenv](https://github.com/pyenv/pyenv), you can create a virtual environment by running `pyenv virtualenv venv_ae_data_flow` and switch to it by using `pyenv activate venv_ae_data_flow`.

If you need to install pyenv, follow [these instructions](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation).

### Install dependencies

Once you have cloned this repo, install the necessary dependencies:

```bash
npm i
pip install --editable .
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

To copy source data files from Digital Ocean, we can use `curl` for public files:

```bash
# for public files
curl --remote-name https://BUCKET.URL.com/folder/folder/data.csv
```

For non-public files like our CSVs in `/edm/distribution/`, we can use [minio](https://github.com/minio/minio).

#### Using brew:

Install
```bash
brew install minio/stable/mc
```

Add DO Spaces to the `mc` configuration
```bash
mc alias set spaces $DO_SPACES_ENDPOINT $DO_SPACES_ACCESS_KEY_ID $DO_SPACES_SECRET_ACCESS_KEY
```
We use `spaces` here but you can name the alias anything. When you run `mc config host list` you should see the newly added host with credentials from your `.env`.

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

### TBD
