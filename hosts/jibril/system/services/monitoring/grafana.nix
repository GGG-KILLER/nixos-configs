{ config, ... }:
{
  jibril.dynamic-ports = [ "grafana" ];

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "socket";
        socket_gid = config.users.groups.caddy.gid;
        root_url = "https://grafana.jibril.lan/";
        enable_gzip = true;
      };
      security = {
        secret_key = "$__file{${config.age.secrets.grafana_secret_key.path}}";
        cookie_secure = true;
        cookie_samesite = "strict";
        content_security_policy = true;
      };
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
  users.users.grafana.extraGroups = [ "caddy" ];

  services.caddy.virtualHosts."grafana.jibril.lan".extraConfig = ''
    reverse_proxy unix/${config.services.grafana.settings.server.socket}
  '';
}
