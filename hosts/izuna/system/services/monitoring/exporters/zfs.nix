{ config, ... }:
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "zfs";
      static_configs = [
        {
          targets = [ "shiro.lan:61004" ];
          labels = {
            instance = "shiro";
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
