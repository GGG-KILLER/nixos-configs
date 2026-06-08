{ lib, config, ... }:
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
    mainAddr = config.home.addrs.shiro-jellyfin;
    ports = [
      {
        protocol = "http";
        port = 8096;
        description = "Jellyfin Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "Caddy";
      }
      {
        protocol = "https";
        port = 443;
        description = "Caddy";
      }
    ];
  };

  containers.jellyfin.autoStart = !config.cost-saving.enable || !config.cost-saving.disable-streaming;

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
    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "/var/lib/jellyfin";
        isReadOnly = false;
      };
      "/var/cache/jellyfin" = {
        hostPath = "/var/cache/jellyfin";
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

    extraFlags = [
      "--property=MemoryMax=1G"
    ];

    config =
      {
        config,
        pkgs,
        ...
      }:
      {
        imports = [ ../../hardware/video.nix ];

        hardware.graphics.enable = true;

        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "nvidia-x11"
            "steam-run"
            "steam-original"
            "steam-unwrapped"
            "ouch"
          ];

        # Jellyfin
        services.jellyfin = {
          # enable = true; # TODO: Uncomment once NixOS/nixpkgs#149715 gets merged.
          user = "streamer";
          group = "data-members";
          package = pkgs.jellyfin;
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

        # Caddy
        ggg.caddy.enable = true;
        ggg.caddy.http-redirect = false;
        services.caddy.virtualHosts = {
          "http://jellyfin.lan, https://jellyfin.lan".extraConfig = "reverse_proxy http://127.0.0.1:8096";
        };
      };
  };
}
