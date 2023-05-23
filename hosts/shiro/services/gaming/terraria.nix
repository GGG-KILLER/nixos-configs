# /zfs-main-pool/data/gaming/terraria
{config, ...}: let
  inherit (config.age) secrets;
in {
  virtualisation.oci-containers.containers.tshock = {
    image = "docker.lan/terraria:tshock-latest";
    cmd = [
      "-secure"
      "-maxplayers"
      "6"
      "-noupnp"
      "-forcepriority"
      "1"
      "-constileation"
    ];
    ports = [
      "7777:7777/tcp"
      "7878:7878/tcp"
    ];
    volumes = [
      "/zfs-main-pool/data/gaming/tshock/Worlds:/root/.local/share/Terraria/Worlds"
      "/zfs-main-pool/data/gaming/tshock/Logs:/tshock/logs"
      "/zfs-main-pool/data/gaming/tshock/Plugins:/plugins"
    ];
    environment = rec {
      TZ = config.time.timeZone;
      WORLD_FILENAME = "GGG_+_Night.wld";
    };
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
      "--cpu-shares=512"
      "--memory=1G"
      "--stop-signal=SIGINT"
    ];
  };

  networking.firewall.allowedTCPPorts = [7777 7878];
}
