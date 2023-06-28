#!/bin/bash

set -o nounset

# since all filenames are assuming they're in the same dir as this script is
# called handle cases where the working directory *isn't* the same directory
cd "$(dirname "$0")" || exit 3

echo "Using ${PSQL_HOST:=localhost}:${PSQL_PORT:=5432} with db ${PSQL_DB:=antismash}, schema ${PSQL_SCHEMA:=asdb_jobs} as ${PSQL_USER:=postgres}"
PSQL="psql -h $PSQL_HOST -p $PSQL_PORT -U $PSQL_USER"
PSQL_AS="$PSQL $PSQL_DB"

$PSQL -tc "SELECT 1 FROM pg_database WHERE datname = '${PSQL_DB}';" | grep -q 1 || $PSQL -c "CREATE DATABASE $PSQL_DB;"

echo "Clearing out the whole schema"
$PSQL_AS -c "DROP SCHEMA IF EXISTS ${PSQL_SCHEMA} CASCADE;" >/dev/null 2>&1

$PSQL_AS -c "CREATE SCHEMA IF NOT EXISTS ${PSQL_SCHEMA};" >/dev/null 2>&1
# tables not depending on other tables
TABLES="controls jobs "

for t in $TABLES; do
	if [ -f "${t}.sql" ]; then
		echo "Processing $t"
	else
		echo "no such file: ${t}.sql"
		exit 1
	fi
	$PSQL_AS 2>&1 <"${t}.sql" | tee tmp | grep ERROR
	if [ "$?" -eq "0" ]; then
		cat tmp
		rm tmp
		exit 1
	fi
	rm tmp
done