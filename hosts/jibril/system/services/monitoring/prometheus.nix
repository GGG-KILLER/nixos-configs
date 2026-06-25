{ config, ... }:
{
  jibril.dynamic-ports = [ "prometheus" ];

  services.prometheus = {
    enable = true;
    port = config.jibril.ports.prometheus;
    checkConfig = true;
    retentionTime = "1y";
    webExternalUrl = "https://prometheus.jibril.lan";
    extraFlags = [ "--web.enable-otlp-receiver" ];
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

  services.caddy.virtualHosts."prometheus.jibril.lan".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.jibril.ports.prometheus}
  '';
}
