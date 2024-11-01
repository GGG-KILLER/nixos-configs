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
  backend = pkgs.callPackage ./package.nix { };
}
