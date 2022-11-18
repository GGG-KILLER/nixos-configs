{
  config,
  lib,
  pkgs,
  ...
} @ args:
with lib; {
  modules.containers.jellyfin = {
    vpn = true;

    hostBridge = "br-ctvpn";
    localAddress = "10.11.0.5/10";

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };
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

    config = {
      config,
      pkgs,
      ...
    }: {
      networking = {
        defaultGateway = "10.11.0.1";
        nameservers = ["10.11.0.1"];
        useHostResolvConf = false;
      };

      # Jellyfin
      services.jellyfin = {
        enable = true;
        user = "streamer";
        group = "data-members";
      };

      environment.systemPackages = with pkgs; [jellyfin-ffmpeg];

      # NGINX
      modules.services.nginx = {
        enable = true;
        virtualHosts = {
          "jellyfin.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.11.0.0/24;

              # Security / XSS Mitigation Headers
              add_header X-Frame-Options "SAMEORIGIN";
              add_header X-XSS-Protection "1; mode=block";
              add_header X-Content-Type-Options "nosniff";
            '';
            locations."= /" = {
              return = "302 http://$host/web/";
            };
            locations."/" = {
              proxyPass = "http://localhost:8096";
              proxyWebsockets = true;
              extraConfig = ''
                # Proxy main Jellyfin traffic
                proxy_read_timeout 6h;

                # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                proxy_buffering off;
              '';
            };
            # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
            locations."= /web/" = {
              proxyPass = "http://localhost:8096/web/index.html";
              extraConfig = ''
                # Proxy main Jellyfin traffic
                proxy_read_timeout 6h;

                # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                proxy_buffering off;
              '';
            };
            locations."/socket" = {
              proxyPass = "http://localhost:8096";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_read_timeout 6h;
              '';
            };
          };
        };
      };
    };
  };
}
