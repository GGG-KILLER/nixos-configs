{ pkgs, config, ... }:
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

  virtualisation.oci-containers.containers.netprobe-redis = {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name redis --image-tag latest --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "redis";
      imageDigest = "sha256:8bc666424ef252009ed34b0432564cabbd4094cd2ce7829306cb1f5ee69170be";
      hash = "sha256-wJoVcrxqYHJcAyUechkPe5/fKGXol0Y/dwjFM9dPg+s=";
      finalImageName = "redis";
      finalImageTag = "latest";
    };
    image = "redis:latest";

    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "${./redis.conf}:/etc/redis/redis.conf:ro" ];
    extraOptions = [
      "--network=netprobe"
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobe-probe = {
    # nix run nixpkgs#nix-prefetch-docker -- --image-name plaintextpackets/netprobe --image-tag latest --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "plaintextpackets/netprobe";
      imageDigest = "sha256:139ed2dcb004324ef7a8d24bbfdd252bfba0012aa2b70575ca92cc38cd2afd56";
      hash = "sha256-3aY0INi+kpFvvp6btIE+E5prH2GofN7/mxcj9udYocI=";
      finalImageName = "plaintextpackets/netprobe";
      finalImageTag = "latest";
    };
    image = "plaintextpackets/netprobe:latest";

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
    # nix run nixpkgs#nix-prefetch-docker -- --image-name plaintextpackets/netprobe --image-tag latest --arch amd64 --os linux --quiet
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "plaintextpackets/netprobe";
      imageDigest = "sha256:139ed2dcb004324ef7a8d24bbfdd252bfba0012aa2b70575ca92cc38cd2afd56";
      hash = "sha256-3aY0INi+kpFvvp6btIE+E5prH2GofN7/mxcj9udYocI=";
      finalImageName = "plaintextpackets/netprobe";
      finalImageTag = "latest";
    };
    image = "plaintextpackets/netprobe:latest";

    environment = {
      MODULE = "PRESENTATION";
    };
    environmentFiles = [ config.age.secrets."netprobe.env".path ];
    volumes = [ "/var/lib/netprobe:/netprobe_lite" ];
    ports = [ "${toString config.shiro.ports.netprobe}:5000" ];
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
          targets = [ "127.0.0.1:${toString config.shiro.ports.netprobe}" ];
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
