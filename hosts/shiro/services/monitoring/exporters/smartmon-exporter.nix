{ config, ... }:
{
  modules.services.smartmon-exporter.enable = true;
  modules.services.smartmon-exporter.listen-addr = "127.0.0.1:${toString config.shiro.ports.prometheus-smartmontools-exporter}";

  services.prometheus.scrapeConfigs = [
    {
      job_name = "smartmontools";
      static_configs = [
        {
          targets = [ config.modules.services.smartmon-exporter.listen-addr ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
