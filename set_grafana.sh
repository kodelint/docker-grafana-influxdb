#!/bin/bash
set -e

if [ -f /.grafana_configured ]; then
    echo "=> grafana has been configured!"
    exit 0
fi

echo "=> Configuring grafana"
# sed -i -e "s#<--INFLUXDB_URL-->#${INFLUXDB_URL}#g" \
#        -e "s/<--DATA_USER-->/${INFLUXDB_DATA_USER}/g" \
#        -e "s/<--DATA_PW-->/${INFLUXDB_DATA_PW}/g" \
#        -e "s/<--GRAFANA_USER-->/${INFLUXDB_GRAFANA_USER}/g" \
#        -e "s/<--GRAFANA_PW-->/${INFLUXDB_GRAFANA_PW}/g" /src/grafana/config.ini
    
touch /.grafana_configured

echo "=> Grafana has been configured as follows:"
echo "   InfluxDB DB DATA NAME:  ${PRE_CREATE_DB}"
echo "   InfluxDB URL: ${INFLUXDB_URL}"
echo "   InfluxDB DB GRAFANA User:  ${INFLUXDB_GRAFANA_USER}"
echo "   InfluxDB DB GRAFANA Password:  ${INFLUXDB_GRAFANA_PW}"
echo "=> Done!"
exit 0
