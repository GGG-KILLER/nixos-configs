{
  lib,
  inputs,
  pkgs,
  ...
}:
let
  reducedInputs = lib.filterAttrs (name: _: name != "self") inputs;
in
{
  nix = {
    package = pkgs.nixVersions.latest;

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
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    # Nix Community Cache
    settings.substituters = [ "https://nix-community.cachix.org" ];
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
