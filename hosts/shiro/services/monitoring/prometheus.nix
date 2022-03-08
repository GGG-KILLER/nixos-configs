{ config, lib, ... }:

with lib;
{
  services.prometheus = {
    enable = true;
    retentionTime = "182d";
    webExternalUrl = "http://prometheus.shiro.lan";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
            labels = { inherit (config.my.constants.prometheus) instance; };
          }
        ];
        inherit (config.my.constants.prometheus) scrape_interval;
      }
    ];
  };

  services.nginx.virtualHosts."prometheus.shiro.lan" = {
    locations."/" = {
      proxyPass = "http://localhost:9090";
    };
  };
}
