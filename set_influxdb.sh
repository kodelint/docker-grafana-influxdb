#!/bin/bash

set -m

CONFIG_FILE="/etc/influxdb/config.toml"
INFLUXDB_HOST="${INFLUXDB_HOST:-localhost}"
INFLUXDB_API_PORT="${INFLUXDB_API_PORT:-8086}"

if [ -n "${INFLUXDB_URL}" ]; then
   echo "INFLUXDB_URL: "${INFLUXDB_URL}
else
   echo "INFLUXDB_URL variable is not set, setting it up"
   INFLUXDB_URL="http://${INFLUXDB_HOST}:${INFLUXDB_API_PORT}"
fi

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
                curl -k ${INFLUXDB_URL}/ping 2> /dev/null
                RET=$?
            done
            echo ""

            PASS=${INFLUXDB_ADMIN_PW:-password}
            if [ -n "${INFLUXDB_ADMIN_USER}" ]; then
            echo "=> Creating admin user"
            influx -host=${INFLUX_HOST} -port=${INFLUXDB_API_PORT} -execute="CREATE USER ${INFLUXDB_ADMIN_USER} WITH PASSWORD '${PASS}' WITH ALL PRIVILEGES"
            influx -host=${INFLUX_HOST} -port=${INFLUXDB_API_PORT} -execute="CREATE USER ${INFLUXDB_GRAFANA_USER} WITH PASSWORD '${INFLUXDB_GRAFANA_PW}' WITH ALL PRIVILEGES"
            for x in $arr
            do
                echo "=> Creating database: ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUXDB_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${PASS}" -execute="create database ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUXDB_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${PASS}" -execute="grant all PRIVILEGES on ${x} to ${INFLUXDB_GRAFANA_USER}"
            done
            echo ""
            else
            for x in $arr
            do
                echo "=> Creating database: ${x}"
                influx -host=${INFLUX_HOST} -port=${INFLUXDB_API_PORT} -execute="create database \"${x}\""
            done
            fi

            touch "/.pre_db_created"
        fi
    fi
    touch "/.influxdb_configured"
fi
#stop influxDB
echo "=> Stopping influxDB to start it under supervisord"
ps aux|grep influxd | awk {'print $2'} | xargs kill -9
exit 0
