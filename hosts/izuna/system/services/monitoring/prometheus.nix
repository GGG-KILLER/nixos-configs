{ config, ... }:
{
  izuna.dynamic-ports = [ "prometheus" ];

  services.prometheus = {
    enable = true;
    port = config.izuna.ports.prometheus;
    checkConfig = true;
    retentionTime = "1y";
    webExternalUrl = "https://prometheus.izuna.lan";
    extraFlags = [ "--web.enable-otlp-receiver" ];
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.izuna.ports.prometheus}" ];
            labels = {
              inherit (config.my.constants.prometheus) instance;
            };
          }
        ];
        inherit (config.my.constants.prometheus) scrape_interval;
      }
    ];
  };

  services.caddy.virtualHosts."prometheus.izuna.lan".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.izuna.ports.prometheus}
  '';
}
