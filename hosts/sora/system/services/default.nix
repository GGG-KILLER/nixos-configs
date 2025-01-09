{ ... }:
{
  imports = [
    ./fancontrol.nix
    ./nix.nix
    ./restic.nix
  ];

  # Docker
  virtualisation.podman.enable = true;
  virtualisation.podman.enableNvidia = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.autoPrune.dates = "daily";
  virtualisation.podman.autoPrune.flags = [ "--all" ];

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # VPN
  services.mullvad-vpn.enable = true;
}
