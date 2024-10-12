{
  lib,
  config,
  pkgs,
  self,
  system,
  ...
}:
{
  systemd.services.live-stream-dvr =
    let
      src = pkgs.fetchzip {
        url = "https://github.com/MrBrax/LiveStreamDVR/releases/download/LiveStreamDVR-2024-04-15-c2.4.2-s1.7.3-d1.1.2-v2.3.2.1/LiveStreamDVR-2024-04-15-c2.4.2-s1.7.3-d1.1.2-v2.3.2.1.zip";
        hash = "sha256-c9OgYZXMmK1wSvOx3nnlNQMk9Vm7C+D+gEjNet++S5o=";
        stripRoot = false;
      };
      bin-dir = pkgs.symlinkJoin {
        name = "live-stream-dvr-bin";
        paths = with pkgs; [
          nodejs
          python39
          ffmpeg
          mediainfo
          self.packages.${system}.twitch-downloader
          streamlink
          yt-dlp
          vcsi
        ];
      };
    in
    {
      after = [ "network.target" ];
      description = "Live Stream DVR";
      wantedBy = [ "multi-user.target" ];
      path = [ bin-dir ];
      environment = {
        TCD_BIN_DIR = "${lib.getBin bin-dir}/bin";
        TCD_FFMPEG_PATH = lib.getExe' bin-dir "ffmpeg";
        TCD_BIN_PATH_PYTHON = lib.getExe' bin-dir "python";
        TCD_BIN_PATH_PYTHON3 = lib.getExe' bin-dir "python3";
        TCD_MEDIAINFO_PATH = lib.getExe' bin-dir "mediainfo";
        TCD_NODE_PATH = lib.getExe' bin-dir "node";
        TCD_TWITCHDOWNLOADER_PATH = lib.getExe' bin-dir "TwitchDownloaderCLI";
        TCD_SERVER_PORT = toString config.shiro.ports.live-stream-dvr;
        TCD_WEBSOCKET_ENABLED = "1";
        TCD_ENABLE_FILES_API = "1";
        TCD_EXPOSE_LOGS_TO_PUBLIC = "1";
        TCD_MIGRATE_OLD_VOD_JSON = "1";
        TCD_PYTHON_ENABLE_PIPENV = "0";
      };
      serviceConfig = {
        User = "downloader";
        Group = "data-members";
        Restart = "always";
        WorkingDirectory = "${src}/server";
        ExecStart = ''
          ${lib.getExe pkgs.nodejs} ./build/server.js \
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
