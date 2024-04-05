{self, ...}: {
  my.networking.qbittorrent = {
    extraNames = ["flood"];
    mainAddr = "192.168.2.154"; # ipgen -n 192.168.2.0/24 qbittorrent
    ports = [
      {
        protocol = "tcp";
        port = 6881;
        description = "DHT?";
      }
      {
        protocol = "udp";
        port = 6881;
        description = "DHT?";
      }
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
      {
        protocol = "http";
        port = 443;
        description = "Local Nginx";
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
      system,
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
        package = self.packages.${system}.flood;
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
        proxyTimeout = "12h";

        virtualHosts = {
          "flood.lan" = {
            default = true;
            ssl = true;
            root = "${pkgs.flood}/lib/node_modules/flood/dist/assets";
            locations."/" = {
              sso = true;
              tryFiles = "$uri /index.html";
            };
            locations."/api" = {
              proxyPass = "http://localhost:${toString config.modules.services.flood.web.port}";
              proxyWebsockets = true;
              sso = true;
              extraConfig = ''
                client_max_body_size 1G;
                proxy_buffering off;
                proxy_cache off;
              '';
            };
          };
          "qbittorrent.lan" = {
            ssl = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString config.modules.services.qbittorrent.web.port}";
              proxyWebsockets = true;
              sso = true;
              extraConfig = ''
                client_max_body_size 1G;
                proxy_buffering off;
                proxy_cache off;
              '';
            };
          };
        };
      };
    };
  };
}
