{ lib, ... }:
{
  imports = [
    ./nix.nix
    #./restic.nix # TODO: Enable backups
  ];

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.docker.daemon.settings = {
    default-address-pools = lib.genList (x: {
      base = "172.${toString (16 + x)}.0.0/16";
      size = 24;
    }) (31 - 16 + 1);
  };
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.persistent = true;
  virtualisation.docker.autoPrune.dates = "22:00";
  virtualisation.docker.autoPrune.flags = [ "--all" ];

  # # VPN
  # services.mullvad-vpn.enable = true;
}
