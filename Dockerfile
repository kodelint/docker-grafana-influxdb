FROM ubuntu:latest

ENV GRAFANA_VERSION 4.3.1
ENV INFLUXDB_VERSION 1.0.0

# Prevent some error messages
ENV DEBIAN_FRONTEND noninteractive

# ---------------- #
#   Installation   #
# ---------------- #

RUN	apt-get -y update && apt-get -y upgrade && apt-get -y install libfontconfig1 wget nginx-light supervisor curl

# Install Grafana to /src/grafana
RUN	curl -s -o /tmp/grafana_${GRAFANA_VERSION}_amd64.deb https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
		dpkg -i /tmp/grafana_${GRAFANA_VERSION}_amd64.deb && \
		rm /tmp/grafana_${GRAFANA_VERSION}_amd64.deb && \
		rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu

# Install InfluxDB
RUN curl -s -o /tmp/influxdb_latest_amd64.deb https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
		dpkg -i /tmp/influxdb_latest_amd64.deb && \
		rm /tmp/influxdb_latest_amd64.deb && \
		rm -rf /var/lib/apt/lists/*
 
# ----------------- #
#   Configuration   #
# ----------------- #

# Env variables
ENV		PRE_CREATE_DB ""
ENV     INFLUXDB_HOST ""
ENV     INFLUXDB_API_PORT ""
ENV		INFLUXDB_URL ""
ENV		INFLUXDB_ADMIN_USER ""
ENV		INFLUXDB_ADMIN_PW ""
ENV		INFLUXDB_GRAFANA_USER ""
ENV		INFLUXDB_GRAFANA_PW ""
ENV		ROOT_PW ""

# Configure Influx and Grafana
ADD		./configure.sh /srv/configure.sh

# Configure InfluxDB
ADD		influxdb/config.toml /etc/influxdb/config.toml 
ADD		influxdb/run.sh /usr/local/bin/run_influxdb
RUN     chmod 777 /usr/local/bin/run_influxdb
ADD		./set_influxdb.sh /srv/set_influxdb.sh

# Configure Grafana
ADD		./grafana/config.ini /etc/grafana/config.ini
ADD		grafana/run.sh /usr/local/bin/run_grafana
RUN     chmod 777 /usr/local/bin/run_grafana
ADD		./set_grafana.sh /srv/set_grafana.sh


# Configure Supervisord
ADD		./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE 3000

# InfluxDB Admin server
EXPOSE 8083

# InfluxDB HTTP API
EXPOSE 8086

# InfluxDB HTTPS API
EXPOSE 8084

# -------- #
#   Run!   #
# -------- #

# CMD	["/usr/bin/supervisord"]
