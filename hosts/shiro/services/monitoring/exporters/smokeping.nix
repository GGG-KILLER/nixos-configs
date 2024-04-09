{config, ...}: {
  services.prometheus.exporters.smokeping = {
    enable = true;
    port = config.shiro.ports.prometheus-smokeping-exporter;
    hosts =
      [
        "192.168.1.1"
      ]
      # Don't want anyone spamming these with pings so security through
      # obscurity it is.
      ++ config.my.secrets.exporters.internet-smokeping-hosts;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "smokeping";
      static_configs = [
        {
          targets = ["127.0.0.1:${toString config.services.prometheus.exporters.smokeping.port}"];
          labels = {inherit (config.my.constants.prometheus) instance;};
        }
      ];
      inherit (config.my.constants.prometheus) scrape_interval;
    }
  ];
}
