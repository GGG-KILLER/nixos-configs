{ self, config, ... }:
{
  my.networking.qbittorrent = {
    extraNames = [ "flood" ];
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

  containers.qbittorrent.autoStart = !config.cost-saving.enable || !config.cost-saving.disable-downloaders;

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
        hostPath = "/var/lib/qbittorrent";
        isReadOnly = false;
      };
    };

    extraFlags = [
      "--property=MemoryMax=2G"
    ];

    config =
      {
        config,
        pkgs,
        system,
        ...
      }:
      {
        # qBitTorrent
        modules.services.qbittorrent = {
          enable = true;
          user = "my-torrent";
          group = "data-members";
          dataDir = "/mnt/qbittorrent/qbittorrent";

          web.port = config.shiro.ports.qbittorrent-web;
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
            url = "http://127.0.0.1:${toString config.modules.services.qbittorrent.web.port}";
            user = "admin";
            password = config.my.secrets.modules.services.qbittorrent.web.password;
          };
          web.port = config.shiro.ports.flood;
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
                # sso = true;
                tryFiles = "$uri /index.html";
              };
              locations."/api" = {
                proxyPass = "http://127.0.0.1:${toString config.modules.services.flood.web.port}";
                recommendedProxySettings = true;
                proxyWebsockets = true;
                # sso = true;
                extraConfig = ''
                  client_max_body_size 0;
                  proxy_buffering off;
                  proxy_cache off;
                '';
              };
            };
            "qbittorrent.lan" = {
              ssl = true;
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString config.modules.services.qbittorrent.web.port}";
                recommendedProxySettings = true;
                proxyWebsockets = true;
                # sso = true;
                extraConfig = ''
                  client_max_body_size 0;
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
