{
  config,
  lib,
  ...
} @ args:
with lib; let
  consts = config.my.constants;
in {
  my.networking.sonarr = {
    extraNames = ["jackett"];
    mainAddr = "192.168.2.46"; # ipgen -n 192.168.2.0/24 sonarr
    ports = [
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

  modules.containers.sonarr = {
    vpn = true;

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };
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

    config = {
      config,
      pkgs,
      ...
    }: {
      # Sonarr
      services.sonarr = {
        enable = true;
        user = "my-sonarr";
        group = "data-members";
        dataDir = "/mnt/sonarr";
      };

      # Jackett
      services.jackett = {
        enable = true;
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
