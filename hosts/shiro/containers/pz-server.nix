{
  config,
  lib,
  inputs,
  ...
} @ args:
with lib; let
  inherit (import ./funcs.nix args) mkContainer;
in {
  my.networking.pz-server = {
    ipAddr = "192.168.1.14";
    ports = [
      {
        protocol = "udp";
        port = 8766;
        description = "Project Zomboid Server";
      }
      {
        protocol = "udp";
        port = 16261;
        description = "Project Zomboid Server";
      }
    ];
  };

  containers.pz-server = mkContainer {
    name = "pz-server";

    nixpkgs = inputs.nixpkgs-stable;

    includeAnimu = false;
    includeSeries = false;
    includeEtc = false;
    includeH = false;

    bindMounts = {
      "/mnt/pz-server" = {
        hostPath = "/zfs-main-pool/data/gaming/pz-server";
        isReadOnly = false;
      };
    };

    config = {
      lib,
      config,
      pkgs,
      ...
    }:
      with lib; {
        options.nix.settings.auto-optimise-store = mkOption {
          type = types.bool;
        };

        config = {
          nixpkgs.config.allowUnfree = true;

          modules.services.pz-server = {
            enable = true;
            serverName = "meandnight";
            serverDir = "/mnt/pz-server";
            adminUserName = "admin";
            adminPassword = "adminggg";
          };
        };
      };
  };
}
