{ ... }:
{
  virtualisation.oci-containers.backend = "docker";

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    autoPrune = {
      enable = true;
      dates = "daily";
      flags = [ "--all" ];
      persistent = true;
      randomizedDelaySec = "45min";
    };
    daemon.settings = {
      default-address-pools = [
        # 4096 subnets with 256 usable hosts per subnet
        {
          base = "172.17.0.0/12";
          size = 24;
        }
        # 4096 subnets with 14 usable hosts per subnet
        {
          base = "192.168.0.0/16";
          size = 28;
        }
      ];
    };
  };
}
