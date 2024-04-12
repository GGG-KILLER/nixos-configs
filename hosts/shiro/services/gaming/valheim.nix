{config, ...}: let
  inherit (config.age) secrets;
in {
  virtualisation.oci-containers.containers.valheim = {
    image = "ghcr.io/lloesche/valheim-server";
    ports = [
      "${toString config.shiro.ports.vallheimUDP_A}-${toString config.shiro.ports.vallheimUDP_C}:2456-2458/udp"
      "${toString config.shiro.ports.vallheim-control-panel}:9001/tcp"
    ];
    volumes = [
      "/zfs-main-pool/data/gaming/valheim/config:/config"
      "/zfs-main-pool/data/gaming/valheim/data:/opt/valheim"
    ];
    environment = {
      TZ = config.time.timeZone;
      SERVER_NAME = "GGG + Night";
      WORLD_NAME = "World";
      BEPINEX = "true";

      SERVER_PUBLIC = "false";
      ADMINLIST_IDS = "76561198044403949 76561198131281776";
      PERMITTEDLIST_IDS = "76561198044403949 76561198131281776";

      BACKUPS_MAX_COUNT = "25";
      BACKUPS_IF_IDLE = "false";

      SUPERVISOR_HTTP = "true";

      PUID = toString config.users.users.valheim.uid;
      PGID = "1000";
    };
    environmentFiles = [
      secrets."valheim-server.env".path
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
      "--memory=4G"
      "--stop-timeout=120"
    ];
  };

  networking.firewall.allowedUDPPorts = with config.shiro.ports; [vallheimUDP_A vallheimUDP_B vallheimUDP_C];
  networking.firewall.allowedTCPPorts = with config.shiro.ports; [vallheimUDP_A vallheimUDP_B vallheimUDP_C];

  modules.services.nginx.virtualHosts."valheim.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.vallheim-control-panel}";
      recommendedProxySettings = true;
    };
  };
}
