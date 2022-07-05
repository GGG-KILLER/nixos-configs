{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
in
{
  my.networking.network-share = {
    ipAddrs = {
      elan = "192.168.1.3";
      # clan = "192.168.2.3";
    };
    ports = [
      {
        protocol = "tcp";
        port = 139;
        description = "NetBIOS Session Service";
      }
      {
        protocol = "tcp";
        port = 445;
        description = "Microsoft DS";
      }
      {
        protocol = "udp";
        port = 137;
        description = "NetBIOS Name Service";
      }
      {
        protocol = "udp";
        port = 138;
        description = "NetBIOS Datagram Service";
      }
    ];
  };

  containers.network-share = mkContainer {
    name = "network-share";

    config = { config, pkgs, ... }:
      {
        # Samba
        services.samba = {
          enable = true;
          securityType = "user";
          extraConfig = ''
            server string = Home Server
            netbios name = HOME-SERVER
            hosts allow = 192.168. localhost
            hosts deny = 0.0.0.0/0
            guest account = nobody
            map to guest = bad user
            smb encrypt = required
            use sendfile = yes
            #vfs objects = acl_xattr
            #map acl inherit = yes
            # the next line is only required on Samba versions less than 4.9.0
            #store dos attributes = yes
          '';
          shares = {
            Animu = {
              path = "/mnt/animu";
              browseable = true;
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0744";
              "directory mask" = "0755";
              "acl group control" = "yes";
            };
            Series = {
              copy = "Animu";
              path = "/mnt/series";
            };
            H = {
              copy = "Animu";
              path = "/mnt/h";
              "csc policy" = "disable";
            };
            Etc = {
              copy = "Animu";
              path = "/mnt/etc";
            };
          };
        };

        environment.systemPackages = [ pkgs.samba ];
      };
  };
}
