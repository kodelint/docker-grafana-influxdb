#!/bin/bash

set -m

exec /src/grafana/bin/grafana-server                                  \
     --homepath=/src/grafana                                          \
     --config=/src/grafana/conf/config.ini                            \
     cfg:default.paths.data="/srv/data/grafana/data/"                  \
     cfg:default.paths.plugins="/srv/data/grafana/plugins"             \
     cfg:default.dashboard.json.enabled=true                          \
     cfg:default.dashboard.json.path="/srv/data/grafana/dashboards"   \
     cfg:default.log.mode="console"                                   \
     "$@"
