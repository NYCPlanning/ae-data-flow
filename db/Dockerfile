# FROM node:20-alpine as pg_parquet
# RUN apk add --no-cache git
# RUN apk add --no-cache openssh
# RUN git clone https://github.com/CrunchyData/pg_parquet.git /tmp 
# WORKDIR /tmp/pg_parquet

# FROM rust:1.40 as rust_builder
# COPY --from=pg_parquet /tmp/pg_parquet /tmp/
# WORKDIR /tmp/pg_parquet
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# RUN apt-get install -y gcc libssl-dev pkg-config
# RUN export CARGO_PGRX_VERSION=0.16.1
# RUN export PG_MAJOR=15
# RUN cargo install --force --locked cargo-pgrx --version "0.16.1"

FROM postgres:15-bookworm

RUN apt-get update 
RUN apt-get install -y postgresql-15-postgis-3
# COPY --from=rust_builder /tmp/pg_parquet /tmp
WORKDIR /var/lib/postgresql


