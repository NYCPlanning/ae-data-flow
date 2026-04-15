FROM debian:trixie AS builder

RUN apt-get update

# Install postgres 15
RUN apt install curl ca-certificates gnupg -y
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/apt.postgresql.org.gpg] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get install -y \
    postgresql-15 \
    postgresql-client-15

# Install rust and cargo
RUN apt-get install -y \
    curl \
    build-essential \
    pkg-config
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y # TODO: change back sh
ENV PATH="/root/.cargo/bin:${PATH}"

# Pull pg_parquet source
RUN apt-get install -y git
RUN git clone https://github.com/CrunchyData/pg_parquet.git
WORKDIR /pg_parquet
# set cargo-pgrx (should be the same as pgrx dep in Cargo.toml) and pg versions
ENV CARGO_PGRX_VERSION=0.16.1
ENV PG_MAJOR=15

# install cargo-pgrx
RUN apt-get install -y libssl-dev
RUN cargo install --force --locked cargo-pgrx@"${CARGO_PGRX_VERSION}"

# configure pgrx
RUN cargo pgrx init --pg"${PG_MAJOR}" $(which pg_config)

# compile pg parquet package for release
RUN apt-get install -y postgresql-server-dev-15
RUN cargo pgrx package

FROM postgres:15-trixie AS postgres

RUN apt-get update
RUN apt-get install -y postgresql-15-postgis-3

COPY --from=builder /pg_parquet/target/release/pg_parquet-pg15/usr/share/postgresql/15/extension /usr/share/postgresql/15/extension
COPY --from=builder /pg_parquet/target/release/pg_parquet-pg15/usr/lib/postgresql/15/lib /lib/postgresql/15/lib

WORKDIR /var/lib/postgresql