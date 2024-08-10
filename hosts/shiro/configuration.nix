{ pkgs, lib, ... }:
with lib;
{
  imports = [
    ./containers
    ./services
    ./users
    ./boot.nix
    ./hardware-configuration.nix
    ./headless.nix
    # ./journald.nix
    ./nat.nix
    ./networking.nix
    ./overrides.nix
    ./ports.nix
    ./secrets.nix
    ./store.nix
    ./users.nix
    ./video.nix
    ./virtualisation.nix
  ];

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    nvtopPackages.nvidia
  ];

  services.openssh.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
