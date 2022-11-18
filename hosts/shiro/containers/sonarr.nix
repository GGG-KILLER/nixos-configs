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
    mainAddr = "10.0.1.4";
    ports = [
      {
        protocol = "http";
        port = 80;
        description = "NGINX";
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
      modules.services.nginx = {
        enable = true;
        virtualHosts = {
          "sonarr.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.0.1.0/24;
            '';
            locations."/".proxyPass = "http://localhost:8989";
          };
          "jackett.lan" = {
            ssl = false;
            extraConfig = ''
              set_real_ip_from 10.0.1.0/24;
            '';
            locations."/".proxyPass = "http://localhost:9117";
          };
        };
      };
    };
  };
}
