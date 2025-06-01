{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.shiro.lan";
      http_addr = "127.0.0.1";
      http_port = config.shiro.ports.grafana;
      root_url = "https://grafana.shiro.lan/";
      enable_gzip = true;
    };

    provision.datasources.settings = {
      apiVersion = 1;

      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString config.shiro.ports.prometheus}";
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

  modules.services.nginx.virtualHosts."grafana.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass =
        with config.services.grafana.settings.server;
        "${protocol}://${http_addr}:${toString http_port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
      '';
    };
  };
}
