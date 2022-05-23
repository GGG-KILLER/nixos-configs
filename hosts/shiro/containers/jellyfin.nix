{ config, lib, pkgs, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
{
  my.networking.jellyfin = {
    useVpn = true;
    ipAddrs = {
      elan = "192.168.1.6";
      # clan = "192.168.2.6";
    };
    ports = [
      {
        protocol = "http";
        port = 8096;
        description = "Jellyfin Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "Local NGINX";
      }
    ];
  };

  containers.jellyfin = mkContainer {
    name = "jellyfin";

    allowedDevices = [
      { node = "/dev/dri/card0"; modifier = "rwm"; }
      { node = "/dev/dri/renderD128"; modifier = "rwm"; }
    ];

    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "/zfs-main-pool/data/jellyfin";
        isReadOnly = false;
      };
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
      {
        # Jellyfin
        services.jellyfin = {
          enable = true;
          user = "streamer";
          group = "data-members";
        };

        # NGINX
        services.nginx = {
          enable = true;
          # recommendedProxySettings = true;
          virtualHosts = {
            "jellyfin.lan" = {
              default = true;
              rejectSSL = true;
              extraConfig = ''
                # Security / XSS Mitigation Headers
                add_header X-Frame-Options "SAMEORIGIN";
                add_header X-XSS-Protection "1; mode=block";
                add_header X-Content-Type-Options "nosniff";
              '';
              locations."= /" = {
                return = "302 http://$host/web/";
              };
              locations."/" = {
                extraConfig = ''
                  # Proxy main Jellyfin traffic
                  proxy_pass http://localhost:8096;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Protocol $scheme;
                  proxy_set_header X-Forwarded-Host $http_host;
                  proxy_read_timeout 6h;

                  # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                  proxy_buffering off;
                '';
              };
              # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
              locations."= /web/" = {
                extraConfig = ''
                  # Proxy main Jellyfin traffic
                  proxy_pass http://localhost:8096/web/index.html;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Protocol $scheme;
                  proxy_set_header X-Forwarded-Host $http_host;
                  proxy_read_timeout 6h;
                '';
              };
              locations."/socket" = {
                extraConfig = ''
                  # Proxy Jellyfin Websockets traffic
                  proxy_pass http://localhost:8096;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Protocol $scheme;
                  proxy_set_header X-Forwarded-Host $http_host;
                  proxy_read_timeout 6h;
                '';
              };
            };
          };
        };
      };
  };
}
