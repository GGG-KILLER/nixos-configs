{ ... }:
{
  imports = [
    ./fancontrol.nix
    ./nix.nix
    ./ollama.nix
    ./restic.nix
  ];

  # Docker
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.autoPrune.dates = "daily";
  virtualisation.podman.autoPrune.flags = [ "--all" ];

  # Allow containers to use nvidia card
  hardware.nvidia-container-toolkit.enable = true;

  # OpenRGB
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # VPN
  services.mullvad-vpn.enable = true;
}
