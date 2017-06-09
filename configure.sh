#!/bin/bash

set -e

if [ ! -f "/.influxdb_configured" ]; then
    echo "Running influxdb setup"
    /srv/set_influxdb.sh
fi

if [ ! -f "/.grafana_configured" ]; then
    echo "Running influxdb setup"
    /srv/set_grafana.sh
fi

