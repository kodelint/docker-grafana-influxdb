#!/bin/bash
set -e

if [ -f /.grafana_configured ]; then
    echo "=> grafana has been configured!"
    exit 0
fi

run_grafana() {
    exec gosu grafana grafana-server                      \
     --homepath=/usr/share/grafana                        \
     --config=/etc/grafana/grafana.ini                    \
     cfg:default.log.mode="console"                       \
     cfg:default.paths.data="/var/lib/grafana"            \
     cfg:default.paths.logs="/var/log/grafana"            \
     cfg:default.paths.plugins="/var/lib/grafana/plugins" \
     "$@"
}

echo "=> Configuring grafana"
touch /.grafana_configured

echo "=> Grafana has been configured as follows:"
echo "   InfluxDB DB DATA NAME:  ${PRE_CREATE_DB}"
echo "   InfluxDB URL: ${INFLUXDB_URL}"
echo "   InfluxDB DB GRAFANA User:  ${INFLUXDB_GRAFANA_USER}"
echo "   InfluxDB DB GRAFANA Password:  ${INFLUXDB_GRAFANA_PW}"
echo "=> Done!"
echo "Starting Grafana"
run_grafana &
exit 0
