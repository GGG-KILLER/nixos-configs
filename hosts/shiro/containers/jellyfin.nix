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
    "/dev/nvidia-modeset"
    "/dev/nvidia-uvm"
    "/dev/nvidia-uvm-tools"
    "/dev/nvidia0"
    "/dev/nvidiactl"
    "/dev/nvram"
  ];
in {
  my.networking.jellyfin = {
    mainAddr = "192.168.1.6";
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
      imports = [../video.nix];

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
        };
      };

      environment.systemPackages = with pkgs; [jellyfin-ffmpeg];

      # NGINX
      security.acme.certs."jellyfin.lan".email = "jellyfin@jellyfin.lan";
      services.nginx = {
        enable = true;
        # recommendedProxySettings = true;
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
