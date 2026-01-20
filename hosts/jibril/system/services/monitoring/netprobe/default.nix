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

  systemd.services."${config.virtualisation.oci-containers.backend}-netprobe-network" =
    let
      backend = config.virtualisation.oci-containers.backend;
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [
        "docker.service"
        "docker.socket"
      ];
      before = [
        "${backend}-netprobe-redis.service"
        "${backend}-netprobe-probe.service"
        "${backend}-netprobe-presentation.service"
      ];
      requiredBy = [
        "${backend}-netprobe-redis.service"
        "${backend}-netprobe-probe.service"
        "${backend}-netprobe-presentation.service"
      ];

      serviceConfig =
        let
          backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
        in
        {
          Type = "simple";
          RemainAfterExit = "yes";

          ExecStartPre = "-${backendBin} network rm netprobe";
          ExecStart = "${backendBin} network create --ipv6 netprobe";
          ExecStop = "${backendBin} network rm netprobe";
        };
    };

  virtualisation.oci-containers.containers.netprobe-redis = rec {
    imageFile = self.packages.${system}.docker-images."redis:latest";
    image = imageFile.destNameTag;

    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "${./redis.conf}:/etc/redis/redis.conf:ro" ];
    extraOptions = [
      "--network=netprobe"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobe-probe = {
    inherit imageFile image;
    environment = {
      MODULE = "NETPROBE";
    };
    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "/var/lib/netprobe:/netprobe_lite" ];
    extraOptions = [
      "--network=netprobe"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobe-presentation = {
    inherit imageFile image;
    environment = {
      MODULE = "PRESENTATION";
    };
    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "/var/lib/netprobe:/netprobe_lite" ];
    ports = [ "${toString config.jibril.ports.netprobe}:5000" ];
    extraOptions = [
      "--network=netprobe"
      "--ipc=none"
    ];
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
