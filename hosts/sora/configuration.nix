# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  self,
  inputs,
  system,
  ...
}:
{
  imports = [
    self.nixosModules.desktop-profile
    ./hardware
    ./system
    ./users/ggg
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./overrides.nix
    ./secrets.nix
    inputs.nur.legacyPackages."${system}".repos.ilya-fedin.modules.io-scheduler
  ];

  # # Host System # TODO: Enable when I have enough patience to rebuild everything
  # nixpkgs.hostPlatform = {
  #   gcc.arch = "znver3";
  #   gcc.tune = "znver3";
  #   system = "x86_64-linux";
  # };

  # Overlays
  nixpkgs.overlays = [ ];

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # Enable CUDA support for everything
  nixpkgs.config.cudaSupport = true;

  # Build chaotic-nyx's packages on top of our nixpkgs instead of theirs.
  chaotic.nyx.overlay.onTopOf = "user-pkgs";

  # Enable broken stuff (Reason)
  # nixpkgs.config.allowBroken = true;

  # # Enable CA derivations by default # TODO: Enable when I have enough patience to rebuild everything
  # nixpkgs.config.contentAddressedByDefault = true;

  networking = {
    hostName = "sora";
    hostId = "6967af45";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = false; # I don't use SSH, this is only so that secrets have a host key.

  networking.firewall.allowedTCPPorts = [
    3389
    6379
  ];
  networking.firewall.allowedUDPPorts = [ 3389 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
