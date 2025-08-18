{ config, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  jibril.dynamic-ports = [ "prometheus" ];

  services.prometheus = {
    enable = true;
    port = config.jibril.ports.prometheus;
    retentionTime = "1y";
    webExternalUrl = "https://prometheus.jibril.lan";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.jibril.ports.prometheus}" ];
            labels = {
              inherit (config.my.constants.prometheus) instance;
            };
          }
        ];
        inherit (config.my.constants.prometheus) scrape_interval;
      }
    ];
  };

  systemd.services.prometheus.serviceConfig.SystemCallFilter = mkForce [
    "@system-service"
    "~@privileged"
  ];

  modules.services.nginx.virtualHosts."prometheus.jibril.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.jibril.ports.prometheus}";
      recommendedProxySettings = true;
    };
  };
}
