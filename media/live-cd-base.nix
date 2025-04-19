{
  self,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ../common/groups
    ../common/users
    ../common/overlays
    ../common/secrets/pki.nix
    ../common/console.nix
    ../common/i18n.nix
    ../common/nix.nix
    ../common/pki.nix
    ../common/time.nix
  ];

  options = {
    home-manager = mkOption { type = types.any; };
    modules.home = mkOption { type = types.any; };
  };

  config = {
    # Use latest kernel if possible.
    # boot.kernelPackages = pkgs.linuxPackages_latest;

    # ISO Options
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    isoImage.storeContents = [
      self.nixosConfigurations.sora.config.system.build.toplevel
      self.nixosConfigurations.shiro.config.system.build.toplevel
    ];

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

    # Graphics Settings
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;

    environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # NOTE: Open kernel module does not work with the Quadro P400
      open = false;
      modesetting.enable = false;
      nvidiaSettings = false;
    };

    environment.systemPackages = with pkgs; [
      croc
      wget
      btop
      file
      iotop-c
      unzip
      zip

      tmux

      btrfs-progs
    ];

    system.activationScripts.linkConfig = ''
      # Link source to /var/nixos-config
      ln -sfn ${toString self} /var/nixos-config
    '';
  };
}
