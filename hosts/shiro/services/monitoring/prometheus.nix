{
  config,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  services.prometheus = {
    enable = true;
    retentionTime = "182d";
    webExternalUrl = "https://prometheus.shiro.lan";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = ["127.0.0.1:9090"];
            labels = {inherit (config.my.constants.prometheus) instance;};
          }
        ];
        inherit (config.my.constants.prometheus) scrape_interval;
      }
    ];
  };

  systemd.services.prometheus.serviceConfig.SystemCallFilter = mkForce ["@system-service" "~@privileged"];

  modules.services.nginx.virtualHosts."prometheus.shiro.lan" = {
    ssl = true;
    locations."/".proxyPass = "http://localhost:9090";
  };
}
