# Github Actions recommends debian:
## https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#from
FROM debian:12.5-slim

# pre-requisites
RUN apt update 
RUN apt install wget ca-certificates libpsl5 libssl3 openssl publicsuffix

# minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc
RUN ./mc --help

# python
RUN apt install python3 python3-pip -y
COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt --break-system-packages

# postgis
RUN apt install -y postgresql-15-postgis-3

COPY bash ./bash
