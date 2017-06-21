#!/bin/bash

set -e

if [ ! -f "/srv/data/.influxdb_configured" ]; then
    echo "=> Configuring influxdb...."
    /usr/local/bin/run_setup_influxdb.sh
fi

if [ ! -f "/srv/data/.grafana_configured" ]; then
    echo "=> Configuring grafana...."
    /usr/local/bin/run_setup_grafana.sh
fi

if [ ! -f "/srv/data/.datasource-added" ]; then
    echo "=> Adding InfluxDB as datasource for Grafana"
    /usr/local/bin/run_setup_stats.sh
fi
