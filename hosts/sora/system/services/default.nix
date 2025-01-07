{ ... }:
{
  imports = [
    ./fancontrol.nix
    ./nix.nix
    ./restic.nix
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    # only start up on demand
    enableOnBoot = false;
  };

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # VPN
  services.mullvad-vpn.enable = true;
}
