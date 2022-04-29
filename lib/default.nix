{ pkgs, ... }:

{
  fs = pkgs.callPackage ./fs.nix { };
}
