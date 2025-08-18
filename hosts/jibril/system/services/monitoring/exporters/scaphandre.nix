{ config, ... }:
{
  services.prometheus.exporters.scaphandre.enable = true;
  services.prometheus.exporters.scaphandre.listenAddress = "127.0.0.1";
  services.prometheus.exporters.scaphandre.port = config.jibril.ports.prometheus-scaphandre-exporter;
  services.prometheus.exporters.scaphandre.extraFlags = [ "--containers" ];

  services.prometheus.scrapeConfigs = [
    {
      job_name = "scaphandre";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.scaphandre.listenAddress}:${toString config.services.prometheus.exporters.scaphandre.port}"
          ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
