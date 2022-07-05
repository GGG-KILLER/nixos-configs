{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  consts = config.my.constants;
in
{
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
        services.nginx = {
          enable = true;
          virtualHosts = {
            "sonarr.lan" = {
              locations."/" = {
                proxyPass = "http://localhost:8989";
              };
            };
            "jackett.lan" = {
              locations."/" = {
                proxyPass = "http://localhost:9117";
              };
            };
          };
        };
      };
  };
}
