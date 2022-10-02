{config, ...}: let
  inherit (config.age) secrets;
in {
  virtualisation.oci-containers.containers.mc-mnn = {
    image = "itzg/minecraft-server:java17-graalvm-ce";
    ports = ["25565:25565"];
    volumes = ["/zfs-main-pool/data/gaming/mc-mnn:/data"];
    environment = {
      VERSION = "1.18.2";
      TYPE = "FABRIC";
      PACKWIZ_URL = "https://github.com/GGG-KILLER/mc-modpacks/raw/main/mnn/pack.toml";
      MEMORY = "2G";
      LOG_TIMESTAMP = "true";
      USE_SIMD_FLAGS = "true";
      USE_AIKAR_FLAGS = "true";

      OVERRIDE_SERVER_PROPERTIES = "true";
      ALLOW_NETHER = "true";
      ANNOUNCE_PLAYER_ACHIEVEMENTS = "true";
      GENERATE_STRUCTURES = "true";
      SNOOPER_ENABLED = "false";
      SPAWN_ANIMALS = "true";
      SPAWN_MONSTERS = "true";
      SPAWN_NPCS = "true";
      MODE = "survival";
      FORCE_GAMEMODE = "true";
      ALLOW_FLIGHT = "true";
      ONLINE_MODE = "false";

      EULA = "TRUE";

      TZ = config.time.timeZone;
    };
    environmentFiles = [
      secrets."mnn-server.env".path
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
    ];
  };

  networking.firewall.allowedTCPPorts = [25565];
  networking.firewall.allowedUDPPorts = [25565];
}
