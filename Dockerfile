FROM ubuntu:latest

ENV GRAFANA_VERSION 4.3.1
ENV INFLUXDB_VERSION 1.0.0

# Prevent some error messages
ENV DEBIAN_FRONTEND noninteractive

# ---------------- #
#   Installation   #
# ---------------- #

RUN	apt-get -y update && apt-get -y upgrade && \
    apt-get -y install libfontconfig1 wget nginx-light supervisor curl python python-setuptools python-pip

    # Install Grafana to /src/grafana
    RUN  mkdir -p src/grafana && cd src/grafana && \
    	wget -nv https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-${GRAFANA_VERSION}.linux-x64.tar.gz -O grafana.tar.gz && \
    	tar xzf grafana.tar.gz --strip-components=1 && rm grafana.tar.gz

# Install InfluxDB
RUN curl -s -o /tmp/influxdb_latest_amd64.deb https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
		dpkg -i /tmp/influxdb_latest_amd64.deb && \
		rm /tmp/influxdb_latest_amd64.deb && \
		rm -rf /var/lib/apt/lists/*

# ----------------- #
#   Configuration   #
# ----------------- #

# Env variables
ENV	PRE_CREATE_DB ""
ENV INFLUXDB_HOST ""
ENV INFLUXDB_API_PORT ""
ENV INFLUXDB_URL ""
ENV	INFLUXDB_ADMIN_USER ""
ENV	INFLUXDB_ADMIN_PW ""
ENV	INFLUXDB_GRAFANA_USER ""
ENV	INFLUXDB_GRAFANA_PW ""
ENV	ROOT_PW ""
ENV	RABBITMQ_NODE ""

# Configure Influx and Grafana
ADD	./configure.sh /usr/local/bin/run_configure.sh

# Configure InfluxDB
ADD	influxdb/config.toml /etc/influxdb/config.toml
ADD	influxdb/run.sh /usr/local/bin/run_influxdb
ADD	./set_influxdb.sh /usr/local/bin/run_setup_influxdb.sh

# Configure Grafana
ADD	./grafana/config.ini /src/grafana/conf/config.ini
ADD	./grafana/run.sh /usr/local/bin/run_grafana
ADD	./set_grafana.sh /usr/local/bin/run_setup_grafana.sh
ADD ./setup_stats.sh /usr/local/bin/run_setup_stats.sh


# Make all runners executable
RUN chmod 755 /usr/local/bin/run_*

# Configure Supervisord
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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

# ---------------- #
#   Run the setup  #
# ---------------- #

CMD bash -c "sh /usr/local/bin/run_configure.sh && /usr/bin/supervisord"
