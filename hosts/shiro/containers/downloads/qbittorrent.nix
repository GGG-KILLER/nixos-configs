{ config, ... }:
{
  my.networking.qbittorrent = {
    mainAddr = config.home.addrs.shiro-qbittorrent;
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
        description = "Caddy";
      }
      {
        protocol = "http";
        port = 443;
        description = "Caddy";
      }
    ];
  };

  containers.qbittorrent.autoStart =
    !config.cost-saving.enable || !config.cost-saving.disable-downloaders;

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
      "/var/lib/qBittorrent" = {
        hostPath = "/var/lib/qBittorrent";
        isReadOnly = false;
      };
    };

    extraFlags = [
      "--property=MemoryMax=2G"
    ];

    config =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "ouch"
          ];

        # qBitTorrent
        services.qbittorrent = {
          enable = true;
          package = pkgs.qbittorrent-nox;
          user = "my-torrent";
          group = "data-members";
          profileDir = "/var/lib/qBittorrent";
          webuiPort = config.shiro.ports.qbittorrent-web;
        };

        # Caddy
        ggg.caddy.enable = true;
        services.caddy.virtualHosts."qbittorrent.lan".extraConfig =
          "reverse_proxy http://127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
      };
  };
}
