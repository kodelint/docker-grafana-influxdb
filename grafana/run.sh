#!/bin/bash

set -m

exec gosu grafana grafana-server                          \
     --homepath=/usr/share/grafana                        \
     --config=/etc/grafana/grafana.ini                    \
     cfg:default.log.mode="console"                       \
     cfg:default.paths.data="/var/lib/grafana"            \
     cfg:default.paths.logs="/var/log/grafana"            \
     cfg:default.paths.plugins="/var/lib/grafana/plugins" \
     "$@"