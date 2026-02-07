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
    self.nixosModules.angrr
    ./hardware
    ./system
    ./users/ggg
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./secrets.nix
    inputs.nur.legacyPackages."${system}".repos.ilya-fedin.modules.io-scheduler
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware info
  nixpkgs.hostPlatform = "x86_64-linux";

  # Facter
  hardware.facter.reportPath = ./facter.json;
  hardware.facter.detected.dhcp.enable = false; # delegate to NetworkManager

  # GC
  ggg.angrr.enable = true;

  # Build chaotic-nyx's packages on top of our nixpkgs instead of theirs.
  chaotic.nyx.overlay.onTopOf = "user-pkgs";

  networking = {
    hostName = "steph";
    hostId = "6967af45";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = false; # Only need the ssh machine key for secrets.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
