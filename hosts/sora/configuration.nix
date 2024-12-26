# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  nur-no-pkgs,
  ...
}:
{
  imports = [
    ./audio
    ./hardware
    ./programs
    ./services
    ./users/ggg
    ./boot.nix
    ./fonts.nix
    # TODO: Undo when this gets fixed in .NET
    ./hack.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nix.nix
    ./overrides.nix
    ./secrets.nix
    nur-no-pkgs.repos.ilya-fedin.modules.io-scheduler
  ];

  # # Host System # TODO: Enable when I have enough patience to rebuild everything
  # nixpkgs.hostPlatform = {
  #   gcc.arch = "znver3";
  #   gcc.tune = "znver3";
  #   system = "x86_64-linux";
  # };

  # Overlays
  nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # Enable CUDA support for everything
  nixpkgs.config.cudaSupport = true;

  # Enable broken stuff (Reason)
  # nixpkgs.config.allowBroken = true;

  # # Enable CA derivations by default # TODO: Enable when I have enough patience to rebuild everything
  # nixpkgs.config.contentAddressedByDefault = true;

  networking = {
    hostName = "sora";
    hostId = "6967af45";
    enableIPv6 = false; # No ISP support.

    nameservers = [ "192.168.1.1" ];
  };

  # Packages
  environment.shells = with pkgs; [
    bash
    powershell
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = false; # I don't use SSH, this is only so that secrets have a host key.

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    3389
    6379
  ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  # Open Tablet thingio
  hardware.opentabletdriver.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Enable Firejail
  programs.firejail.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
