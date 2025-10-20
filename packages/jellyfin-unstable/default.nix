{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {
    inherit system;
    config = {
      allowUnfree = true;
    };
  },
}:
{
  jellyfin-unstable = pkgs.callPackage ./package.nix {
    jellyfin-web-unstable = pkgs.callPackage ../jellyfin-web-unstable/package.nix;
  };
}
