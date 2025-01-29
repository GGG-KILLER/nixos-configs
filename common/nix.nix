{ inputs, pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.latest;

    # Flakes
    settings.experimental-features = [
      "auto-allocate-uids"
      "ca-derivations"
      "cgroups"
      "flakes"
      "nix-command"
    ];
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nur.flake = inputs.nur;
      home-manager.flake = inputs.home-manager;
    };

    # Path Things
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nur=${inputs.nur}"
      "home-manager=${inputs.home-manager}"
    ];

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
