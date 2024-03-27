{
  inputs,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.nix_2_21;

    # Flakes
    settings.experimental-features = ["nix-command" "flakes"];
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nixpkgs-stable.flake = inputs.nixpkgs-stable;
      nur.flake = inputs.nur;
      home-manager.flake = inputs.home-manager;
    };

    # Path Things
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nixpkgs-stable=${inputs.nixpkgs-stable}"
      "nur=${inputs.nur}"
      "home-manager=${inputs.home-manager}"
    ];

    # Auto Optimise the Store
    settings.auto-optimise-store = true;
    optimise.automatic = true;
  };
}
