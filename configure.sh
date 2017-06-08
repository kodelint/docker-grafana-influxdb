#!/bin/bash

set -e

if [ ! -f "/.influxdb_configured" ]; then
    /srv/set_influxdb.sh
fi

if [ ! -f "/.grafana_configured" ]; then
    /srv/set_grafana.sh
fi

