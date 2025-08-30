{ inputs, ... }:
{
  config = {
    nix.settings = {
      # add binary caches
      trusted-public-keys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      substituters = [ "https://nixpkgs-wayland.cachix.org" ];
    };

    # use it as an overlay
    nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];
  };
}
