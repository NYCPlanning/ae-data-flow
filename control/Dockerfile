FROM node:24-bookworm

RUN apt-get update
RUN apt-get install -y postgresql-client-15

WORKDIR /app

RUN npm i -g tsx@^4.21.0

COPY ./package.json .
COPY ./package-lock.json .
RUN npm ci
