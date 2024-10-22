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
      ASPNETCORE_ENVIRONMENT = "Production";
      ASPNETCORE_HTTP_PORTS = toString config.shiro.ports.live-stream-dvr;
      ASPNETCORE_HTTPS_PORTS = "";

      DVR_Binaries__StreamLinkPath = lib.getExe pkgs.streamlink;
      DVR_Binaries__FfmpegPath = lib.getExe pkgs.ffmpeg;
      # DVR_Binaries__MediaInfoPath = lib.getExe pkgs.mediainfo;
      # DVR_Binaries__TwitchDownloaderCliPath = lib.getExe self.packages.${system}.twitch-downloader;
    };
    serviceConfig = {
      User = "downloader";
      Group = "data-members";
      Restart = "always";
      ExecStart = lib.getExe self.packages.${system}.livestreamdvr-net-backend;
      WorkingDirectory = "/zfs-main-pool/data/services/live-stream-dvr";
    };
  };

  modules.services.nginx.virtualHosts."ttv.ggg.dev" = {
    ssl = true;

    locations."/api/" = {
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.live-stream-dvr}/";
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
