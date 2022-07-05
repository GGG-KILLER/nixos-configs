{ config, lib, ... }:

with lib;
let
  instance = "shiro";
  scrape_interval = "5s";
in
{
  services.grafana = rec {
    enable = true;
    domain = "grafana.shiro.lan";
    rootUrl = "http://${domain}/";
  };

  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
            labels = { inherit instance; };
          }
        ];
        inherit scrape_interval;
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            labels = { inherit instance; };
          }
        ];
        inherit scrape_interval;
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [ "127.0.0.1:9134" ];
            labels = { inherit instance; };
          }
        ];
        inherit scrape_interval;
      }
    ];
  };

  modules.services.node-exporter-smartmon.enable = true;
  modules.services.zfs-exporter.enable = true;

  services.nginx.virtualHosts = {
    "grafana.shiro.lan" = {
      locations."/" = {
        proxyPass = with config.services.grafana; "${protocol}://${addr}:${toString port}";
      };
    };
    "prometheus.shiro.lan" = {
      locations."/" = {
        proxyPass = "http://localhost:9090";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];
  networking.firewall.allowedUDPPorts = [ config.services.grafana.port ];
}
