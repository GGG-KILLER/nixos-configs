{ config, ... }:
{
  services.prometheus.exporters.zfs = {
    enable = true;
    port = config.shiro.ports.prometheus-zfs-exporter;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "zfs";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
