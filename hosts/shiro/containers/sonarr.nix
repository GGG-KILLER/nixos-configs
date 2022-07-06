{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
{
  my.networking.sonarr = {
    useVpn = true;
    extraNames = [ "jackett" ];
    ipAddrs = {
      elan = "192.168.1.5";
      # clan = "192.168.2.5";
    };
    ports = [
      {
        protocol = "http";
        port = 8989;
        description = "Sonarr Web UI";
      }
      {
        protocol = "http";
        port = 9117;
        description = "Jackett Web UI";
      }
      {
        protocol = "http";
        port = 80;
        description = "NGINX";
      }
      {
        protocol = "http";
        port = 443;
        description = "Local Nginx";
      }
    ];
  };

  containers.sonarr = mkContainer {
    name = "sonarr";

    bindMounts = {
      "/mnt/sonarr" = {
        hostPath = "/zfs-main-pool/data/sonarr";
        isReadOnly = false;
      };
      "/mnt/jackett" = {
        hostPath = "/zfs-main-pool/data/jackett";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
      {
        # Sonarr
        services.sonarr = {
          enable = true;
          openFirewall = true;
          user = "my-sonarr";
          group = "data-members";
          dataDir = "/mnt/sonarr";
        };

        # Jackett
        services.jackett = {
          enable = true;
          openFirewall = true;
          user = "my-sonarr";
          group = "data-members";
          dataDir = "/mnt/jackett";
        };

        # NGINX
        security.acme.certs."sonarr.lan".email = "sonarr@sonarr.lan";
        security.acme.certs."jackett.lan".email = "jackett@soarr.lan";
        services.nginx = {
          enable = true;
          virtualHosts = {
            "sonarr.lan" = {
              enableACME = true;
              addSSL = true;
              locations."/" = {
                proxyPass = "http://localhost:8989";
              };
            };
            "jackett.lan" = {
              enableACME = true;
              addSSL = true;
              locations."/" = {
                proxyPass = "http://localhost:9117";
              };
            };
          };
        };
      };
  };
}
