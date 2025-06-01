{ config, ... }:
{
  modules.services.smartmon-exporter.enable = true;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "lm_sensors";
      static_configs = [
        {
          targets = [ config.modules.services.smartmon-exporter.socket-path ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
