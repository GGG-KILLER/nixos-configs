# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  inputs,
  nur-no-pkgs,
  ...
}: {
  imports = [
    ./audio
    ./backup/restic.nix
    ./users/ggg
    ./docker.nix
    ./fancontrol.nix
    ./fonts.nix
    ./gnome.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nix.nix
    ./openrgb.nix
    ./overrides.nix
    ./rustdesk.nix
    ./secrets.nix
    ./video.nix
    ./virtualisation.nix
    ./vpn.nix
    ./webcam.nix
    ./yubikey.nix
    ./zfs.nix
    nur-no-pkgs.repos.ilya-fedin.modules.flatpak-fonts
    nur-no-pkgs.repos.ilya-fedin.modules.flatpak-icons
    nur-no-pkgs.repos.ilya-fedin.modules.io-scheduler
  ];

  # Overlays
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # LQX kernel
  # TODO: Remove override when NixOS/nixpkgs#298049 arrives on unstable.
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_lqx.override {
    structuredExtraConfig = with lib.kernel; {
      UCLAMP_TASK = lib.mkForce (option no);
      UCLAMP_TASK_GROUP = lib.mkForce (option no);
    };
  });

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # Enable CUDA support for everything
  nixpkgs.config.cudaSupport = true;

  networking = {
    hostName = "sora";
    hostId = "6967af45";
    enableIPv6 = false; # No ISP support.

    nameservers = ["192.168.1.1"];
  };

  # Packages
  environment.shells = with pkgs; [bash powershell];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # TODO: Enable firewall
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

  # Android
  programs.adb.enable = true;

  # easyeffects needs this
  programs.dconf.enable = true;

  # Corsair Keyboard
  hardware.ckb-next.enable = true;

  # Chrome SUID
  security.chromiumSuidSandbox.enable = true;

  # Steam Controller
  hardware.xone.enable = true;
  hardware.steam-hardware.enable = true;

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
