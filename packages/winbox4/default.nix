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
  winbox4 = pkgs.callPackage ./package.nix { };
}
