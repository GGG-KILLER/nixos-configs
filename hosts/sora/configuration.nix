# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, nur, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ../../common
      ./audio.nix
      ./docker.nix
      ./fonts.nix
      ./gnome.nix
      ./hardware-configuration.nix
      ./home-manager.nix
      ./video.nix
      ./users/ggg.nix
      nur.repos.ilya-fedin.modules.flatpak-fonts
      nur.repos.ilya-fedin.modules.flatpak-icons
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # ZFS boot settings.
  boot.supportedFilesystems = [ "zfs" "ntfs" ];
  boot.zfs.devNodes = "/dev/";

  networking.hostName = "sora";
  networking.hostId = "6967af45";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Packages
  environment.shells = with pkgs; [ bash powershell ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Flatpak
  services.flatpak.enable = true;

  # libvirtd
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
  };

  # Firmware Update
  services.fwupd.enable = true;

  # I2C
  hardware.i2c.enable = true;

  # Enable AMD Microcode Updating
  hardware.cpu.amd.updateMicrocode = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # git-credential-manager has /usr/bin/which hardcoded.
  system.activationScripts.usr-bin-which = ''
    mkdir -p /usr/bin
    rm /usr/bin/which
    ln -sfn ${pkgs.which}/bin/which /usr/bin/which
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
