#!/bin/bash

generate_post_data()
{
  cat <<EOF
  {
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
   }
EOF
}

configure_datasource() {
    echo "Wating for 20 seconds"
    sleep 20
    curl -s 'http://localhost:3000/api/datasources' -X POST -uadmin:admin -H 'Content-Type: application/json' -d "$(generate_post_data)"
    touch /srv/data/.datasource-added
}


if [ ! -f "/srv/data/.final_setup_done" ]; then
    configure_datasource
    echo ""
    echo "========================================================="
    echo "=> Grafana has been configured with InfluxDB:"
    echo "   InfluxDB DB DATA NAME: ${PRE_CREATE_DB}"
    echo "   InfluxDB URL: ${INFLUXDB_URL}"
    echo "   InfluxDB DB GRAFANA User: ${INFLUXDB_GRAFANA_USER}"
    echo "   InfluxDB DB GRAFANA Password: ${INFLUXDB_GRAFANA_PW}"
    echo "=> Done!"
    echo "========================================================="
    echo ""
    echo "=> Stopping influxDB, Grafana to start it under supervisord"
    ps aux|grep influxd|awk {'print $2'} | xargs kill -9
    ps aux|grep grafana-server|awk {'print $2'} | xargs kill -9
    touch /srv/data/.final_setup_done
else
    echo "=> Setup is already there.."
fi
