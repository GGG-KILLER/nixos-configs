{
  config,
  lib,
  ...
} @ args:
with lib; let
  consts = config.my.constants;
in {
  my.networking.qbittorrent = {
    extraNames = ["flood"];
    mainAddr = "10.0.1.3";
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
    ];
  };

  modules.containers.qbittorrent = {
    vpn = true;
    timeoutStartSec = "5min";

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };

    bindMounts = {
      "/mnt/qbittorrent" = {
        hostPath = "/zfs-main-pool/data/qbittorrent";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      # qBitTorrent
      modules.services.qbittorrent = {
        enable = true;
        user = "my-torrent";
        group = "data-members";
        dataDir = "/mnt/qbittorrent/qbittorrent";
      };

      # Flood
      modules.services.flood = {
        enable = true;
        package = pkgs.local.npm."@jesec/flood";
        rundir = "/mnt/qbittorrent/flood";
        auth = "none";
        allowedpath = [
          "/mnt/animu"
          "/mnt/series"
          "/mnt/h"
          "/mnt/etc"
        ];
        qbittorrent = {
          url = "http://localhost:${toString config.modules.services.qbittorrent.web.port}";
          user = "admin";
          password = config.my.secrets.modules.services.qbittorrent.web.password;
        };
      };

      # NGINX
      modules.services.nginx = {
        enable = true;
        virtualHosts = {
          "flood.lan" = {
            ssl = false;
            root = "${pkgs.flood}/lib/node_modules/flood/dist/assets";
            extraConfig = ''
              set_real_ip_from 10.0.1.0/24;
            '';
            locations."/" = {
              tryFiles = "$uri /index.html";
            };
            locations."/api" = {
              proxyPass = "http://localhost:${toString config.modules.services.flood.web.port}";
              proxyWebsockets = true;
              extraConfig = ''
                client_max_body_size 1G;
                proxy_buffering off;
                proxy_cache off;
                proxy_read_timeout 6h;
              '';
            };
          };
          "qbittorrent.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.0.1.0/24;
            '';
            locations."/" = {
              proxyPass = "http://localhost:${toString config.modules.services.qbittorrent.web.port}";
              proxyWebsockets = true;
              extraConfig = ''
                client_max_body_size 1G;
                proxy_buffering off;
                proxy_cache off;
                proxy_read_timeout 6h;
              '';
            };
          };
        };
      };
    };
  };
}
