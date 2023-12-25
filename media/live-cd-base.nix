{
  modulesPath,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
in {
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
    home-manager = mkOption {
      type = types.any;
    };
    modules.home = mkOption {
      type = types.any;
    };
  };

  config = let
    stableDriver = config.boot.kernelPackages.nvidiaPackages.stable;
    unstableDriver = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaDriver =
      if (lib.versionOlder unstableDriver.version stableDriver.version)
      then stableDriver
      else unstableDriver;
  in {
    # Use latest kernel if possible.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # ISO naming.
    isoImage.isoBaseName = "${config.system.nixos.distroId}-${config.isoImage.edition}";

    # NVIDIA drivers are unfree.
    nixpkgs.config.allowUnfree = true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Don't need firewall while installing, probably
    networking.firewall.enable = false;

    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.enable = true;

    environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
    hardware.nvidia = {
      package = stableDriver;

      # NOTE: Open kernel module does not work with the Quadro P400
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
    ];
  };
}
