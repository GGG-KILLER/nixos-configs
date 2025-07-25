{ pkgs, config, ... }:
let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name plaintextpackets/netprobe --image-tag latest --arch amd64 --os linux --quiet
  imageFile = pkgs.dockerTools.pullImage {
    imageName = "plaintextpackets/netprobe";
    imageDigest = "sha256:139ed2dcb004324ef7a8d24bbfdd252bfba0012aa2b70575ca92cc38cd2afd56";
    hash = "sha256-3aY0INi+kpFvvp6btIE+E5prH2GofN7/mxcj9udYocI=";
    finalImageName = "plaintextpackets/netprobe";
    finalImageTag = "latest";
  };
  image = imageFile.destNameTag;
in
{
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
          ExecStart = "${backendBin} network create netprobe";
          ExecStop = "${backendBin} network rm netprobe";
        };
    };

  virtualisation.oci-containers.containers.netprobe-redis = rec {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name redis --image-tag latest --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "redis";
      imageDigest = "sha256:1b7c17f650602d97a10724d796f45f0b5250d47ee5ba02f28de89f8a1531f3ce";
      hash = "sha256-VP1qZ5yoS58IHrLg0n3S7GcSDkt13ns7dwGDzu0w9hE=";
      finalImageName = "redis";
      finalImageTag = "latest";
    };
    image = imageFile.destNameTag;

    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "${./redis.conf}:/etc/redis/redis.conf:ro" ];
    extraOptions = [
      "--network=netprobe"
      "--dns=192.168.1.1"
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
      "--dns=192.168.1.1"
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
      "--dns=192.168.1.1"
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
