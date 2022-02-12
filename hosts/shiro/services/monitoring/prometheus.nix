{ config, lib, ... }:

with lib;
let
  instance = "shiro";
  scrape_interval = "5s";
in
{
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

  services.nginx.virtualHosts."prometheus.shiro.lan" = {
    locations."/" = {
      proxyPass = "http://localhost:9090";
    };
  };
}
