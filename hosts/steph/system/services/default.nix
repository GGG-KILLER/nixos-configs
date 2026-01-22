{ ... }:
{
  imports = [
    ./nix.nix
    #./restic.nix # TODO: Enable backups
  ];

  # Docker
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.autoPrune.dates = "daily";
  virtualisation.podman.autoPrune.flags = [ "--all" ];

  # # VPN
  # services.mullvad-vpn.enable = true;
}
