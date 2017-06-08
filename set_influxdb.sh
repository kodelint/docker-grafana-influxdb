#!/bin/bash

set -m
CONFIG_FILE="/etc/influxdb/config.toml"
INFLUX_HOST='localhost'
INFLUX_API_PORT=${INFLUX_API_PORT:-8086}
API_URL="http://localhost:8086"

echo "=> About to create the following database: ${PRE_CREATE_DB}"
if [ -f "/.influxdb_configured" ]; then
    echo "=> Database had been created before, skipping ..."
else
    echo "=> Starting InfluxDB ..."
    exec /usr/bin/influxd -config=${CONFIG_FILE} &
    # Pre create database on the initiation of the container
    if [ -n "${PRE_CREATE_DB}" ]; then
        echo "=> About to create the following database: ${PRE_CREATE_DB}"
        if [ -f "/.pre_db_created" ]; then
            echo "=> Database had been created before, skipping ..."
        else
            arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

            #wait for the startup of influxdb
            RET=1
            while [[ RET -ne 0 ]]; do
                echo "=> Waiting for confirmation of InfluxDB service startup ..."
                sleep 3
                curl -k ${API_URL}/ping 2> /dev/null
                RET=$?
            done
            echo ""

            PASS=${INFLUXDB_ADMIN_PW:-password}
            if [ -n "${INFLUXDB_ADMIN_USER}" ]; then
            echo "=> Creating admin user"
            influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE USER ${INFLUXDB_ADMIN_USER} WITH PASSWORD '${PASS}' WITH ALL PRIVILEGES"
            for x in $arr
            do
                echo "=> Creating database: ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${PASS}" -execute="create database ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${PASS}" -execute="grant all PRIVILEGES on ${x} to ${INFLUXDB_ADMIN_USER}"
            done
            echo ""
            else
            for x in $arr
            do
                echo "=> Creating database: ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="create database \"${x}\""
            done
            fi

            touch "/.pre_db_created"
        fi
    fi
    touch "/.influxdb_configured"
fi

exit 0
