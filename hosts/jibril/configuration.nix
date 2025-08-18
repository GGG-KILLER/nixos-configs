# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware
    ./system
    ./users/ggg
    ./disk-config.nix
    ./hardware-configuration.nix
    ./ports.nix
    ./secrets.nix
  ];

  boot.kernelModules = [ "intel_rapl_common" ];
  boot.supportedFilesystems = [ "btrfs" ];
  nixpkgs.hostPlatform = "x86_64-linux";

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree stuff.
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
  ];

  # Enable sysdig
  programs.sysdig.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
