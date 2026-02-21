{ lib, pkgs, ... }:
{
  imports = [
    ./desktop
    ./fonts.nix
    ./nix.nix
  ];

  # Giving up on 100% pure nix, I want .NET AOT
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc # libdl
    gtk3 # libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-3.so.0 libgdk-3.so.0
    libGL # libGL.so.1
    libice # libICE.so.6
    libsm # libSM.so.6
    libx11 # libX11 libX11.so.6
    libxcursor # libXcursor.so.1
    libxi # libXi.so.6
    libxrandr # libXrandr.so.2
    fontconfig # libfontconfig.so.1
  ];

  # Programs
  environment.systemPackages = with pkgs; [
    # Nix
    nix-output-monitor

    # Media
    ffmpeg

    # Terminal tools
    uutils-coreutils-noprefix
  ];

  # Enable mtr
  programs.mtr.enable = true;

  # Kernel params
  boot.kernelParams = [
    # ZFS-related params
    "zfs.zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}"
    "elevator=none"
    "nohibernate"
  ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc;

  # Scheduler
  services.scx.enable = true;
  services.scx.package = pkgs.scx.rustscheds;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];

  # ZFS boot settings.
  boot.supportedFilesystems = {
    zfs = true;
    ntfs = true;
  };

  # Make the root partition ephemeral
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@blank
  '';
  chaotic.zfs-impermanence-on-shutdown.enable = true;
  chaotic.zfs-impermanence-on-shutdown.volume = "rpool/nixos/root";
  chaotic.zfs-impermanence-on-shutdown.snapshot = "blank";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
