{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
in
{
  my.networking.pz-server = {
    ipAddrs = {
      elan = "192.168.1.14";
      # clan = "192.168.2.3";
    };
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

    includeAnimu = false;
    includeEtc = false;
    includeH = false;

    bindMounts = {
      "/mnt/pz-server" = {
        hostPath = "/zfs-main-pool/data/gaming/pz-server";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
      {
        modules.services.pz-server = {
          enable = true;
          serverName = "meandnight";
          serverDir = "/mnt/pz-server";
          adminUserName = "gggadmin";
          adminPassword = "adminggg";
        };
      };
  };
}
