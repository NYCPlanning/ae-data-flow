DROP TABLE IF EXISTS
    budget_request
    CASCADE;

CREATE TABLE if NOT EXISTS policy_area (
    id text,
    policy_area text
)

CREATE TABLE if NOT EXISTS need_group (
    id text,
    need_group text
)

CREATE TABLE if NOT EXISTS type_br (
    id text,
    type_br text
)

CREATE TABLE if NOT EXISTS need (
    id text,
    need text
)

CREATE TABLE if NOT EXISTS request (
    id text,
    request text
)

CREATE TABLE IF NOT EXISTS budget_request (
    id text,
    borough
)