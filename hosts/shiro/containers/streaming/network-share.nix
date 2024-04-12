{...}: {
  my.networking.network-share = {
    mainAddr = "192.168.2.7"; # ipgen -n 192.168.2.0/24 network-share
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

    config = {
      config,
      pkgs,
      ...
    }: {
      # Samba
      services.samba = {
        enable = true;
        nsswins = true;
        enableNmbd = true;
        securityType = "user";
        extraConfig = ''
          server string = Home Server
          netbios name = HOME-SERVER
          hosts allow = 192.168. 127.0.0.1
          hosts deny = 0.0.0.0/0
          guest account = nobody
          map to guest = bad user
          smb encrypt = required
          use sendfile = yes
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
