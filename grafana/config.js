// == Configuration
// config.js is where you will find the core Grafana configuration. This file contains parameter that
// must be set before Grafana is run for the first time.

define(['settings'], function(Settings) {
  

  return new Settings({

      /* Data sources
      * ========================================================
      * Datasources are used to fetch metrics, annotations, and serve as dashboard storage
      *  - You can have multiple of the same type.
      *  - grafanaDB: true    marks it for use for dashboard storage
      *  - default: true      marks the datasource as the default metric source (if you have multiple)
      *  - basic authentication: use url syntax http://username:password@domain:port
      */

      // InfluxDB example setup (the InfluxDB databases specified need to exist)
      
      datasources: {
        data: {
          type: 'influxdb',
          url: "<--INFLUXDB_URL-->/db/data",
          username: '<--DATA_USER-->',
          password: '<--DATA_PW-->',
        },
        grafana: {
          type: 'influxdb',
          url: "<--INFLUXDB_URL-->/db/grafana",
          username: '<--GRAFANA_USER-->',
          password: '<--GRAFANA_PW-->',
          grafanaDB: true
        },
      },
      admin: {
        password: 'password'
      },
    });
});



