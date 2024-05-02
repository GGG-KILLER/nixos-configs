{
  config,
  pkgs,
  ...
}: {
  system.activationScripts.create-netprobe-network = let
    docker = config.virtualisation.oci-containers.backend;
    dockerBin = "${pkgs.${docker}}/bin/${docker}";
  in ''
    ${dockerBin} network inspect netprobe >/dev/null 2>&1 || ${dockerBin} network create netprobe
  '';

  virtualisation.oci-containers.containers.netprobe-redis = {
    image = "redis:latest";

    environmentFiles = [config.age.secrets."netprobe.env".path];
    volumes = [
      "${./redis.conf}:/etc/redis/redis.conf:ro"
    ];
    extraOptions = [
      "--network=netprobe"
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobe-probe = {
    image = "plaintextpackets/netprobe:latest";

    environment = {
      MODULE = "NETPROBE";
    };
    environmentFiles = [config.age.secrets."netprobe.env".path];
    volumes = [
      "/zfs-main-pool/data/netprobe:/netprobe_lite"
    ];
    extraOptions = [
      "--network=netprobe"
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  virtualisation.oci-containers.containers.netprobe-presentation = {
    image = "plaintextpackets/netprobe:latest";

    environment = {
      MODULE = "PRESENTATION";
    };
    environmentFiles = [config.age.secrets."netprobe.env".path];
    volumes = [
      "/zfs-main-pool/data/netprobe:/netprobe_lite"
    ];
    ports = [
      "${toString config.shiro.ports.netprobe}:5000"
    ];
    extraOptions = [
      "--network=netprobe"
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };
}
