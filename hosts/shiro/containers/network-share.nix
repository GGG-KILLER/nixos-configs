{
  config,
  lib,
  ...
} @ args:
with lib; {
  my.networking.network-share = {
    mainAddr = "10.0.0.3";
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

  modules.containers.network-share = {
    ephemeral = false;

    builtinMounts = {
      animu = true;
      series = true;
      etc = true;
      h = true;
    };

    forwardPorts = [
      # NetBIOS Session Service
      {
        protocol = "tcp";
        hostPort = 139;
      }
      # Microsoft DS
      {
        protocol = "tcp";
        hostPort = 445;
      }
      # NetBIOS Name Service
      {
        protocol = "udp";
        hostPort = 137;
      }
      # NetBIOS Datagram Service
      {
        protocol = "udp";
        hostPort = 138;
      }
    ];

    config = {
      config,
      pkgs,
      ...
    }: {
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

      environment.systemPackages = [pkgs.samba];
    };
  };
}
