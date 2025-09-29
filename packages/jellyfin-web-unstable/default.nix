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
  jellyfin-web-unstable = pkgs.callPackage ./package.nix { };
}
