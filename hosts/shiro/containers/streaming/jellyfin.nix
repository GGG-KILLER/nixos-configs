{
  config,
  lib,
  pkgs,
  ...
} @ args:
with lib; let
  consts = config.my.constants;
  gpuDevs = [
    "/dev/dri"
    "/dev/shm"
    "/dev/nvidia-uvm"
    "/dev/nvidia-uvm-tools"
    "/dev/nvidia0"
    "/dev/nvidiactl"
    "/dev/nvram"
  ];
in {
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

  containers.jellyfin.allowedDevices =
    map (dev: {
      modifier = "rw";
      node = dev;
    })
    gpuDevs;

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
      // (listToAttrs (map (dev:
        nameValuePair dev {
          hostPath = dev;
          isReadOnly = false;
        })
      gpuDevs));

    config = {
      config,
      pkgs,
      ...
    }: {
      imports = [../../video.nix];

      hardware.opengl.enable = true;

      nixpkgs.config.allowUnfreePredicate = pkg:
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

      systemd.packages = [pkgs.jellyfin];
      systemd.services.jellyfin = let
        cfg = config.services.jellyfin;
      in {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = rec {
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "jellyfin";
          CacheDirectory = "jellyfin";
          ExecStart = "${cfg.package}/bin/jellyfin --datadir '/var/lib/${StateDirectory}' --cachedir '/var/cache/${CacheDirectory}'";
          Restart = "always";
        };
      };

      environment.systemPackages = with pkgs; [jellyfin-ffmpeg];

      # NGINX
      security.acme.certs."jellyfin.lan".email = "jellyfin@jellyfin.lan";
      services.nginx = {
        enable = true;

        proxyTimeout = "12h";
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedZstdSettings = true;

        virtualHosts = {
          "jellyfin.lan" = {
            default = true;

            enableACME = true;
            addSSL = true;

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
              proxyPass = "http://localhost:8096";
              proxyWebsockets = true;
              extraConfig = ''
                # Disable buffering when the nginx proxy gets very resource heavy upon streaming
                proxy_buffering off;
              '';
            };

            # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
            locations."= /web/" = {
              proxyPass = "http://localhost:8096/web/index.html";
            };
          };
        };
      };
    };
  };
}
