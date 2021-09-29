#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    create role dba with superuser noinherit;
    grant dba to gvm;
    create extension "uuid-ossp";
    create extension "pgcrypto";
EOSQL
