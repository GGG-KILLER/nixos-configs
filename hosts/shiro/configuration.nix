{ self, config, pkgs, ... }:
{
  imports = [
    self.nixosModules.server-profile
    ./containers
    ./services
    ./users
    ./boot.nix
    ./cost-saving.nix
    ./hardware-configuration.nix
    ./nat.nix
    ./networking.nix
    ./ports.nix
    ./secrets.nix
    ./store.nix
    ./video.nix
    ./virtualisation.nix
  ];

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # Enable CUDA support for everything
  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    nvtopPackages.nvidia
    config.boot.kernelPackages.turbostat
    nmon
    parted
    btrfs-progs
  ];

  services.openssh.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
  ];

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;

  # Enable sysdig
  programs.sysdig.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
