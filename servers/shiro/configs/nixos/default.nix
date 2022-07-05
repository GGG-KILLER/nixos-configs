{ ... }:
{
  imports = [
    ./boot.nix
    ./gpu.nix
    ./hardware-config.nix
    ./headless.nix
    ./nat.nix
    ./networking.nix
    ./store.nix
  ];
}
