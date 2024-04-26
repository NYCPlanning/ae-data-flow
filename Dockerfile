FROM ubuntu:jammy

RUN apt-get update

# RUN apt install -y wget gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates
RUN apt-get install -y wget 
RUN apt-get install -y software-properties-common

# ogr2ogr
RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get update
RUN apt-get install -y gdal-bin

# psql from postgres-client
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-client-15


# minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc
RUN mv mc /usr/local/bin

# python
COPY requirements.txt /requirements.txt
RUN apt-get install -y python3 python3-pip
RUN pip install -r requirements.txt 

# dbt
## config
COPY dbt_project.yml /dbt_project.yml
COPY package-lock.yml /package-lock.yml
COPY packages.yml /packages.yml
COPY profiles.yml /profiles.yml
## install
RUN apt-get install -y git
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

CMD ["sleep", "infinity"]
