{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "openwrt";
      static_configs = [
        {
          targets = [ "192.168.1.1:9100" ];
          labels = {
            instance = "openwrt";
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
