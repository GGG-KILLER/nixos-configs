{
  lib,
  config,
  pkgs,
  self,
  system,
  ...
}:
{
  systemd.services.live-stream-dvr = {
    after = [ "network.target" ];
    description = "Live Stream DVR";
    wantedBy = [ "multi-user.target" ];
    environment = {
      TCD_TWITCHDOWNLOADER_PATH = lib.getExe self.packages.${system}.twitch-downloader;
      TCD_SERVER_PORT = toString config.shiro.ports.live-stream-dvr;
      TCD_WEBSOCKET_ENABLED = "1";
      TCD_ENABLE_FILES_API = "1";
      TCD_EXPOSE_LOGS_TO_PUBLIC = "1";
      TCD_MIGRATE_OLD_VOD_JSON = "1";
    };
    serviceConfig = {
      User = "downloader";
      Group = "data-members";
      Restart = "always";
      ExecStart = ''
        ${lib.getExe self.packages.${system}.livestreamdvr} \
          --dataroot /zfs-main-pool/data/services/live-stream-dvr \
          --port ${toString config.shiro.ports.live-stream-dvr}
      '';
    };
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
