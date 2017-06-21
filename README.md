docker-grafana-influxdb
=======================

This image contains a sensible default configuration of InfluxDB and Grafana. It explicitly doesn't bundle an example dashboard.

### Versions ###
Grafana: [4.3.1](https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.3.1.linux-x64.tar.gz)  
InfluxDB: [1.0.0](https://dl.influxdata.com/influxdb/releases/influxdb_1.2.4_amd64.deb)

### Using the Dashboard ###

Once your container is running all you need to do is open your browser pointing to the host/port you just published and play with the dashboard at your wish. We hope that you have a lot of fun with this image and that it serves it's purpose of making your life easier.

### Building the image yourself ###

The Dockerfile and supporting configuration files are available in this Github repository. This comes specially handy if you want to change any of the InfluxDB or Grafana settings, or simply if you want to know how the image was built.
The repo also has `build`, `start` and `stop` scripts to make your workflow more pleasant.

### Docker Compose ###
You can do `docker-compose` as well to after `build`

### Configuring the settings  ###

The container exposes the following ports by default:

- `3000`: Grafana web interface.
- `8083`: InfluxDB Admin web interface.
- `8084`: InfluxDB HTTPS API (not usable by default).
- `8086`: InfluxDB HTTP API.

To start a container with your custom config: see `start` script.

To change ports, consider the following:

- `3000`: edit `Dockerfile, port for grafana and start script`.
- `8083`: edit: `Dockerfile, influxDB/config.toml and start script`.
- `8084`: edit: to be announced.
- `8086`: edit: `Dockerfile, influxDB/config.toml, grafana/config.ini, set_influxdb.sh and start script`.

#### Credits  
 * [Satyajit Roy](kodelint@gmail.com)
