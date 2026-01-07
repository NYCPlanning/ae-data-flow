## TODO:
Make simpler by placing the whole node app in the volume


# Description

Use "execa" in node environemt to run utilities like "pg_dump" and "psql" with

## Setup

Scripts run inside a docker environemt that includes:
- Node to run the "execa" library using "tsx"
- Linux-based utilies like postgres-client

Docker container is built with:
```bash
docker compose build control
```

## Updating dependencies
The docker container will use the "package.json" and "package-lock.json" files as they exist when running the build command.

To upgrade the dependencies change into the "control" directory.

From there, run the npm scripts to manage the packages

Finally, rerun the command to build the control container

## Update scripts
The scripts are attached to the control docker container with a volume.
As the scripts are updated in the local machine, they are updated in the docker container

## Running a script
The scripts are run within the control container using tsx (which is install globally)
```bash
docker compose run --rm control tsx scripts/hello.ts
```
