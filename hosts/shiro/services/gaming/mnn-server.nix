{config, ...}: let
  inherit (config.age) secrets;
in {
  virtualisation.oci-containers.containers.mc-mnn = {
    image = "itzg/minecraft-server:java17-graalvm-ce";
    ports = [
      "25565:25565"
      "25566:25566"
    ];
    volumes = ["/zfs-main-pool/data/gaming/mc-mnn:/data"];
    environment = {
      VERSION = "1.18.2";
      TYPE = "FABRIC";
      PACKWIZ_URL = "https://mc.ggg.dev/mnn-2/pack.toml";
      MEMORY = "4G";
      LOG_TIMESTAMP = "true";
      USE_SIMD_FLAGS = "true";
      USE_AIKAR_FLAGS = "true";
      SEED = "-2218787502936624024";

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
      SPAWN_PROTECTION = "0";
      RCON_CMDS_STARTUP = ''
        /chunky spawn
        /chunky radius 10000
        /chunky start
        /gamerule doInsomnia false
      '';
      RCON_CMDS_FIRST_CONNECT = ''
        /chunky pause
      '';
      RCON_CMDS_LAST_DISCONNECT = ''
        /chunky continue
      '';

      EULA = "TRUE";

      TZ = config.time.timeZone;
    };
    environmentFiles = [
      secrets."mnn-server.env".path
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
    ];
  };

  networking.firewall.allowedTCPPorts = [25565 25566];
  networking.firewall.allowedUDPPorts = [25565 25566];
}
