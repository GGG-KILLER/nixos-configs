{
  self,
  config,
  pkgs,
  ...
}:
{
  imports = with self.nixosModules; [
    common-programs
    groups
    i18n
    nix-settings
    home-pki
    users
    zsh
  ];

  # ISO Options
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  # isoImage.storeContents = [
  #   self.nixosConfigurations.sora.config.system.build.toplevel
  # ];

  # Enable ZFS
  boot.zfs.package = pkgs.zfs_unstable;

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfree = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Don't need firewall while installing, probably
  networking.firewall.enable = false;

  # Allow to login with the ggg user SSH key
  users.users.nixos.openssh.authorizedKeys.keys = config.users.users.ggg.openssh.authorizedKeys.keys;

  environment.systemPackages = with pkgs; [
    croc
    wget
    btop
    file
    iotop-c

    tmux

    btrfs-progs
  ];

  system.activationScripts.linkConfig = ''
    # Link source to /var/nixos-config
    ln -sfn ${toString ../.} /var/nixos-config
  '';

  nixpkgs.hostPlatform = "x86_64-linux";
  isoImage.squashfsCompression = "zstd";
}
