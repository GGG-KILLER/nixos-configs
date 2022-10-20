{
  config,
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:
with lib; {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./containers
    ./networking
    ./services
    ./boot.nix
    ./gpu.nix
    ./hardware-configuration.nix
    ./headless.nix
    ./journald.nix
    ./nat.nix
    ./secrets.nix
    ./store.nix
    ./users.nix
    ./virtualisation.nix
  ];

  # We want xlibs because we want cached stuff.
  environment.noXlibs = false;

  # We actually *do* want documentation.
  documentation = {
    enable = true;
    nixos.enable = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  services.openssh.enable = true;

  # Firmware
  nixpkgs.config.allowUnfree = true;
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  # hardware.enableAllFirmware = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
