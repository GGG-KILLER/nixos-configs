{ config, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = config.shiro.ports.prometheus-node-exporter;
    enabledCollectors = [
      "systemd"
      "processes"
    ];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
