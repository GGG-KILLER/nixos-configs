{...}: {
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
    }: let
      jackett = pkgs.callPackage ../../../../common/packages/jackett {};
    in {
      # Sonarr
      services.sonarr = {
        enable = true;
        package = pkgs.sonarr.overrideAttrs (final: prev: rec {
          version = "4.0.2.1183";

          src = pkgs.fetchurl {
            url = "https://github.com/Sonarr/Sonarr/releases/download/v${version}/Sonarr.main.${version}.linux-x64.tar.gz";
            hash = "sha256-S9j6zXEJM963tki88awPW0uK0fQd1bBwBcsHBlDSg/E=";
          };
        });
        user = "my-sonarr";
        group = "data-members";
        dataDir = "/mnt/sonarr";
      };

      # Jackett
      services.jackett = {
        enable = true;
        package = jackett;
        user = "my-sonarr";
        group = "data-members";
        dataDir = "/mnt/jackett";
      };

      # NGINX
      security.acme.certs."sonarr.lan".email = "sonarr@sonarr.lan";
      security.acme.certs."jackett.lan".email = "jackett@soarr.lan";
      services.nginx = {
        enable = true;

        proxyTimeout = "12h";
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedZstdSettings = true;

        virtualHosts = {
          "sonarr.lan" = {
            enableACME = true;
            addSSL = true;

            locations."/" = {
              proxyPass = "http://localhost:8989";
              proxyWebsockets = true;
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
