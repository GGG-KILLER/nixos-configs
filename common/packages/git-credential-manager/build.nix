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
  out = pkgs.callPackage ./default.nix { };
}
