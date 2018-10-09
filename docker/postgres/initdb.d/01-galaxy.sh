#!/bin/bash

set -o errexit
set -o nounset

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<-EOF
    CREATE USER galaxy WITH LOGIN PASSWORD 'galaxy';
    CREATE DATABASE galaxy OWNER galaxy;
EOF
