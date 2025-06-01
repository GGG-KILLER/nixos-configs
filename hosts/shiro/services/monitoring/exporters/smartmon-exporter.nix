{ config, ... }:
{
  modules.services.smartmon-exporter.enable = true;
  modules.services.smartmon-exporter.port = config.shiro.ports.prometheus-smartmontools-exporter;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "smartmontools";
      static_configs = [
        {
          targets = [ "${config.modules.services.smartmon-exporter.addr}:${toString config.modules.services.smartmon-exporter.port}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
      scrape_timeout = "50s";
    }
  ];
}
