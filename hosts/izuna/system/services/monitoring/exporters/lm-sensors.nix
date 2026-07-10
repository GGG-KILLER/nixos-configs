{ config, ... }:
{
  izuna.dynamic-ports = [ "prometheus-lm-sensors-exporter" ];

  ggg.lm-sensors-exporter = {
    enable = true;
    port = config.izuna.ports.prometheus-lm-sensors-exporter;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "lm_sensors";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.ggg.lm-sensors-exporter.port}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
        {
          targets = [ "shiro.lan:61001" ];
          labels = {
            instance = "shiro";
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
