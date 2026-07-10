{
  config,
  self,
  system,
  ...
}:
let
in
{
  izuna.dynamic-ports = [ "netprobesharp" ];

  virtualisation.oci-containers.containers.netprobesharp = rec {
    imageFile = self.packages.${system}.docker-images."gggdotdev/netprobesharp:dev";
    image = imageFile.destNameTag;
    environmentFiles = [ config.age.secrets."netprobesharp.env".path ];
    ports = [ "127.0.0.1:${toString config.izuna.ports.netprobesharp}:9464" ];
    extraOptions = [ "--ipc=none" ];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "netprobesharp";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.izuna.ports.netprobesharp}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
            isp = "Co";
          };
        }
      ];
      scrape_interval = "30s";
      scrape_timeout = "25s";
    }
  ];
}
