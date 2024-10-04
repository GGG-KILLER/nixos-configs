{ config, ... }:
{
  virtualisation.oci-containers.containers.live-stream-dvr = {
    image = "mrbrax/twitchautomator:master";
    ports = [
      "${toString config.shiro.ports.live-stream-dvr}:8080"
    ];
    volumes = [
      "/zfs-main-pool/data/services/live-stream-dvr:/usr/local/share/twitchautomator/data"
    ];
    environment = {
      TZ = config.time.timeZone;
      NODE_ENV = "production";
      TCD_ENABLE_FILES_API = "1";
      TCD_EXPOSE_LOGS_TO_PUBLIC = "1";
      TCD_MIGRATE_OLD_VOD_JSON = "1";
    };
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--pull=always"
    ];
  };

  modules.services.nginx.virtualHosts."ttv.ggg.dev" = {
    ssl = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.live-stream-dvr}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  security.acme.certs."ttv.ggg.dev" = {
    email = "gggkiller2@gmail.com";
    server = "https://acme-v02.api.letsencrypt.org/directory";
    renewInterval = "daily";
  };

  services.cloudflared.tunnels."3c1b8ea8-a43d-4a97-872c-37752de30b3f".ingress."ttv.ggg.dev" = "https://127.0.0.1";
}
