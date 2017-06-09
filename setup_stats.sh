#!/bin/bash

configure_datasource() {
    echo "Wating for 20 seconds"
    sleep 20
    curl -s 'http://localhost:3000/api/datasources' -X POST -uadmin:admin -H 'Content-Type: application/json' -d '{
        "name":"events",
        "type":"influxdb", 
        "url":"http://${INFLUXDB_HOST}:${INFLUXDB_API_PORT}", 
        "access":"proxy",
        "jsonData":{},
        "secureJsonFields":{}, 
        "isDefault":true,
        "database":"${PRE_CREATE_DB}",
        "user":"${INFLUXDB_GRAFANA_USER}",
        "password":"${INFLUXDB_GRAFANA_PW}"
}'
    touch /srv/stats/.datasource-added
}

configure_datasource
#stop influxDB
echo ""
echo "=> Stopping influxDB, Grafana to start it under supervisord"
ps aux|grep influxd|awk {'print $2'} | xargs kill -9
ps aux|grep grafana|awk {'print $2'} | xargs kill -9
