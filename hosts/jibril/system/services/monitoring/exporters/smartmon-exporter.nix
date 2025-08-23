{ config, ... }:
{
  jibril.dynamic-ports = [ "prometheus-smartctl-exporter" ];
  services.prometheus.exporters.smartctl.enable = true;
  services.prometheus.exporters.smartctl.listenAddress = "127.0.0.1";
  services.prometheus.exporters.smartctl.port = config.jibril.ports.prometheus-smartctl-exporter;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "smartctl";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.smartctl.listenAddress}:${toString config.services.prometheus.exporters.smartctl.port}"
          ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
        {
          targets = [ "shiro.lan:61003" ];
          labels = {
            instance = "shiro";
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
