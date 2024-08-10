{ self, lib, ... }:
let
  inherit (lib) getExe' listToAttrs nameValuePair;
  gpuDevs = [
    "/dev/dri"
    "/dev/shm"
    "/dev/nvidia-uvm"
    "/dev/nvidia-uvm-tools"
    "/dev/nvidia0"
    "/dev/nvidiactl"
    "/dev/nvram"
  ];
in
{
  my.networking.jellyfin = {
    mainAddr = "192.168.2.219"; # ipgen -n 192.168.2.0/24 jellyfin
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
      {
        protocol = "http";
        port = 443;
        description = "Local Nginx";
      }
    ];
  };

  containers.jellyfin.allowedDevices = map (dev: {
    modifier = "rw";
    node = dev;
  }) gpuDevs;

  modules.containers.jellyfin = {
    vpn = true;

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };
    bindMounts =
      {
        "/var/lib/jellyfin" = {
          hostPath = "/zfs-main-pool/data/jellyfin";
          isReadOnly = false;
        };
        "/var/cache/jellyfin" = {
          hostPath = "/zfs-main-pool/data/jellyfin/var-cache";
          isReadOnly = false;
        };
      }
      // (listToAttrs (
        map (
          dev:
          nameValuePair dev {
            hostPath = dev;
            isReadOnly = false;
          }
        ) gpuDevs
      ));

    config =
      {
        config,
        pkgs,
        system,
        ...
      }:
      {
        imports = [ ../../video.nix ];
        security.pki.certificateFiles = [ config.my.secrets.pki.root-crt-path ];

        hardware.graphics.enable = true;

        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "nvidia-x11"
            "steam-run"
            "steam-original"
          ];

        # Jellyfin
        services.jellyfin = {
          # enable = true; # TODO: Uncomment once NixOS/nixpkgs#149715 gets merged.
          user = "streamer";
          group = "data-members";
        };

        systemd.packages = [ pkgs.jellyfin ];
        systemd.services.jellyfin =
          let
            cfg = config.services.jellyfin;
          in
          {
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = rec {
              User = cfg.user;
              Group = cfg.group;
              StateDirectory = "jellyfin";
              CacheDirectory = "jellyfin";
              ExecStart = "${getExe' cfg.package "jellyfin"} --datadir '/var/lib/${StateDirectory}' --cachedir '/var/cache/${CacheDirectory}'";
              Restart = "always";
            };
          };

        environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

        # NGINX
        modules.services.nginx = {
          enable = true;
          proxyTimeout = "12h";

          virtualHosts."jellyfin.lan" = {
            ssl = true;

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
              proxyPass = "http://127.0.0.1:8096";
              recommendedProxySettings = true;
              proxyWebsockets = true;
              extraConfig = ''
                # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                proxy_buffering off;
              '';
            };

            # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
            locations."= /web/" = {
              proxyPass = "http://127.0.0.1:8096/web/index.html";
              recommendedProxySettings = true;
              extraConfig = ''
                # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                proxy_buffering off;
              '';
            };
          };
        };
      };
  };
}
