{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.nix-settings;

  defaultOn = desc: (mkEnableOption desc) // { default = true; };

  reducedInputs = lib.filterAttrs (name: _: name != "self") inputs;
in
{
  options.ggg.nix-settings = {
    enable = mkEnableOption "the pre-configured nix settings (package, flakes, registry, nixPath)";
    optimise = defaultOn "automatic nix store optimisation";
    community-cache = defaultOn "the nix-community cachix binary cache";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.nix_2_31;

      # Check config
      checkConfig = true;
      checkAllErrors = true;

      # Disable channels
      channel.enable = false;

      # Flakes
      settings.experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
      ];
      registry = lib.mapAttrs' (name: value: lib.nameValuePair name { flake = value; }) reducedInputs;

      # Path Things
      nixPath = lib.mapAttrsToList (name: value: "${name}=${value}") reducedInputs;

      # Auto Optimise the Store
      settings.auto-optimise-store = mkIf cfg.optimise true;
      optimise.automatic = mkIf cfg.optimise true;

      # Nix Community Cache
      settings.substituters = mkIf cfg.community-cache [ "https://nix-community.cachix.org" ];
      settings.trusted-public-keys = mkIf cfg.community-cache [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
