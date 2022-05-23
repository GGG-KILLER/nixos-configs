{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
{
  my.networking.qbittorrent = {
    useVpn = true;
    extraNames = [ "flood" ];
    ipAddrs = {
      elan = "192.168.1.10";
      # clan = "192.168.2.10";
    };
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
        port = config.modules.services.qbittorrent.web.port;
        description = "qBitTorrent Web UI";
      }
      {
        protocol = "http";
        port = config.modules.services.flood.web.port;
        description = "Flood UI";
      }
    ];
  };

  containers.qbittorrent = mkContainer {
    name = "qbittorrent";

    bindMounts = {
      "/mnt/qbittorrent" = {
        hostPath = "/zfs-main-pool/data/qbittorrent";
        isReadOnly = false;
      };
    };
    config = { config, pkgs, ... }:
      {
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
          rundir = "/mnt/qbittorrent/flood";
          auth = "none";
          allowedpath = [
            "/mnt/animu"
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
        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          virtualHosts = {
            "flood.lan" = {
              default = true;
              rejectSSL = true;
              root = "${pkgs.flood}/lib/node_modules/flood/dist/assets";
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
              rejectSSL = true;
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
