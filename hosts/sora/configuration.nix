# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  nur-no-pkgs,
  ...
}: {
  imports = [
    ./audio
    ./backup/restic.nix
    ./docker.nix
    ./fancontrol.nix
    ./fonts.nix
    ./gnome.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nix.nix
    ./overrides.nix
    ./rustdesk.nix
    ./secrets.nix
    ./users/ggg
    ./video.nix
    ./virtualisation.nix
    ./vpn.nix
    ./webcam.nix
    ./yubikey.nix
    ./zfs.nix
    nur-no-pkgs.repos.ilya-fedin.modules.flatpak-fonts
    nur-no-pkgs.repos.ilya-fedin.modules.flatpak-icons
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LQX kernel
  boot.kernelPackages = pkgs.linuxPackages_lqx;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  # # ZFS marked as broken on 6.1 LQX but it works.
  # nixpkgs.config.allowBroken = pkgs.linuxPackages_lqx.zfsUnstable.name == "zfs-kernel-2.1.8-staging-2023-01-10-6.1.3";

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "sora";
    hostId = "6967af45";

    nameservers = ["192.168.1.1"];
  };

  # Packages
  environment.shells = with pkgs; [bash powershell];

  # Enable CUPS to print documents.
  #services.printing.enable = true;

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

  # I2C
  hardware.i2c.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  # hardware.enableAllFirmware = true;

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Corsair Keyboard
  hardware.ckb-next.enable = true;

  # Chrome SUID
  security.chromiumSuidSandbox.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
