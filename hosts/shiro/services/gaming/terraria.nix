# /zfs-main-pool/data/gaming/terraria
{config, ...}: let
  inherit (config.age) secrets;
in {
  virtualisation.oci-containers.containers.terraria = {
    image = "ryshe/terraria:vanilla-latest";
    ports = ["7777:7777/tcp"];
    volumes = [
      # We don't mount into /root/.local/share/Terraria because /root/.local/share/Terraria/Worlds is a declared mount in the image
      # which means it'll replace the World directory that would be inside that
      "/zfs-main-pool/data/gaming/terraria:/Terraria"
    ];
    environment = rec {
      TZ = config.time.timeZone;
      CONFIGPATH = "/Terraria";
      WORLDPATH = "${CONFIGPATH}/Worlds";
      LOGPATH = "${CONFIGPATH}/Logs";
      WORLD_FILENAME = "GGG_+_Night.wld";
    };
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
    ];
  };

  networking.firewall.allowedTCPPorts = [7777];
}
