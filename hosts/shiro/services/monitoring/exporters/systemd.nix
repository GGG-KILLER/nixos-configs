{ config, ... }:
{
  services.prometheus.exporters.systemd.enable = true;
  services.prometheus.exporters.systemd.port = config.shiro.ports.prometheus-exporter;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "systemd";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.shiro.ports.prometheus-exporter}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
