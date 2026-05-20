{
  self,
  system,
  config,
  ...
}:
let
  imageFile = self.packages.${system}.docker-images."plaintextpackets/netprobe:latest";
  image = imageFile.destNameTag;
in
{
  jibril.dynamic-ports = [ "netprobe" ];

  virtualisation.oci-containers.networks.netprobe = { };

  virtualisation.oci-containers.containers.netprobe-redis = rec {
    imageFile = self.packages.${system}.docker-images."redis:latest";
    image = imageFile.destNameTag;

    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "${./redis.conf}:/etc/redis/redis.conf:ro" ];
    networks = [ "netprobe" ];
    extraOptions = [ "--ipc=none" ];
  };

  virtualisation.oci-containers.containers.netprobe-probe = {
    inherit imageFile image;
    environment = {
      MODULE = "NETPROBE";
    };
    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "/var/lib/netprobe:/netprobe_lite" ];
    networks = [ "netprobe" ];
    extraOptions = [ "--ipc=none" ];
  };

  virtualisation.oci-containers.containers.netprobe-presentation = {
    inherit imageFile image;
    environment = {
      MODULE = "PRESENTATION";
    };
    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "/var/lib/netprobe:/netprobe_lite" ];
    ports = [ "${toString config.jibril.ports.netprobe}:5000" ];
    networks = [ "netprobe" ];
    extraOptions = [ "--ipc=none" ];
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "netprobe";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString config.jibril.ports.netprobe}" ];
          labels = {
            inherit (config.my.constants.prometheus) instance;
          };
        }
      ];
      scrape_interval = "30s";
      scrape_timeout = "25s";
    }
  ];
}
