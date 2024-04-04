# Github Actions recommends debian:
## https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#from
FROM postgres:15-bookworm

# pre-requisites
RUN apt update 
RUN apt install -y wget ca-certificates libpsl5 libssl3 openssl publicsuffix

# postgis
RUN apt install -y postgresql-15-postgis-3

# minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc

# python
COPY requirements.txt /requirements.txt
RUN apt install -y python3 python3-pip
RUN pip install -r requirements.txt --break-system-packages

# dbt
## config
COPY dbt_project.yml /dbt_project.yml
COPY package-lock.yml /package-lock.yml
COPY packages.yml /packages.yml
COPY profiles.yml /profiles.yml
## install
RUN apt install -y git
RUN dbt deps
## tests
COPY tests /tests

# etl
## scripts
COPY bash ./bash
## commands
COPY sql /sql
## local source files
COPY borough.csv /borough.csv
COPY land_use.csv /land_use.csv
COPY zoning_district_class.csv /zoning_district_class.csv 
