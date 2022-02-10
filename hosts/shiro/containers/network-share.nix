{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
in
{
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
            H = {
              copy = "animu";
              path = "/mnt/h";
              "csc policy" = "disable";
            };
            Etc = {
              copy = "animu";
              path = "/mnt/etc";
            };
          };
        };

        environment.systemPackages = [ pkgs.samba ];
      };
  };
}
