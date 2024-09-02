{ ... }:
{
  my.networking.pz-server = {
    mainAddr = "192.168.2.40"; # ipgen --network 192.168.2.0/24 pz-server
    ports = [
      {
        protocol = "tcp";
        port = 27015;
        description = "Steam Port";
      }
      {
        protocol = "udp";
        port = 16261;
        description = "Project Zomboid Server";
      }
      {
        protocol = "udp";
        port = 16262;
        description = "Project Zomboid Server";
      }
    ];
  };

  modules.containers.pz-server = {
    timeoutStartSec = "2min";

    bindMounts = {
      "/mnt/pz-server" = {
        hostPath = "/zfs-main-pool/data/gaming/pz-server";
        isReadOnly = false;
      };
    };

    config =
      { ... }:
      {
        nixpkgs.config.allowUnfree = true;

        modules.services.pz-server = {
          enable = true;
          serverName = "mnn2";
          serverDir = "/mnt/pz-server";
          adminUserName = "gggadmin";
          adminPassword = "adminggg";
        };
      };
  };
}
