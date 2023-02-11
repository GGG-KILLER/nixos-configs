{config, ...}: {
  modules.services.lm-sensors-exporter.enable = true;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "lm_sensors";
      static_configs = [
        {
          targets = ["127.0.0.1:${toString config.modules.services.lm-sensors-exporter.port}"];
          labels = {inherit (config.my.constants.prometheus) instance;};
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
