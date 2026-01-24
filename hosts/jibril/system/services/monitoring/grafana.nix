{ config, ... }:
{
  jibril.dynamic-ports = [ "grafana" ];

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.jibril.lan";
      http_addr = "127.0.0.1";
      http_port = config.jibril.ports.grafana;
      root_url = "https://grafana.jibril.lan/";
      enable_gzip = true;
    };

    provision.datasources.settings = {
      apiVersion = 1;

      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString config.jibril.ports.prometheus}";
          jsonData = {
            cacheLevel = "Low";
            defaultEditor = "code";
            disableRecordingRules = true;
            httpMethod = "POST";
            incrementalQuerying = true;
            manageAlerts = false;
            prometheusType = "Prometheus";
            prometheusVersion = config.services.prometheus.package.version;
            timeInterval = config.my.constants.prometheus.scrape_interval;
          };
        }
      ];
    };
  };

  services.caddy.virtualHosts."grafana.jibril.lan".extraConfig = ''
    reverse_proxy ${
      with config.services.grafana.settings.server; "${protocol}://${http_addr}:${toString http_port}"
    }
  '';
}
