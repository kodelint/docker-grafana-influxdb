#!/bin/bash
set -e

if [ -f /srv/data/.grafana_configured ]; then
    echo "=> Grafana has already been configured!"
    exit 0
fi

run_grafana() {
     exec /src/grafana/bin/grafana-server                               \
       --homepath=/src/grafana                                          \
       --config=/src/grafana/conf/config.ini                            \
       cfg:default.paths.data="/srv/data/grafana/data/"                 \
       cfg:default.paths.plugins="/srv/data/grafana/plugins"            \
       cfg:default.dashboard.json.enabled=true                          \
       cfg:default.dashboard.json.path="/srv/data/grafana/dashboards"   \
       cfg:default.log.mode="console"                                   \
       "$@"
}

echo "=> Creating folder structure"
mkdir -p /srv/data/grafana/{data,plugins,dashboards}
touch /srv/data/.grafana_configured
echo "-> Starting Grafana"
run_grafana &
exit 0
