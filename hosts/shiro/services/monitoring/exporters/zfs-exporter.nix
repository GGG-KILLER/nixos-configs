{config, ...}: {
  modules.services.zfs-exporter.enable = true;

  services.prometheus.scrapeConfigs = [
    {
      job_name = "zfs";
      static_configs = [
        {
          targets = ["127.0.0.1:9134"];
          labels = {inherit (config.my.constants.prometheus) instance;};
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
