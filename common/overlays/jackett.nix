{ lib, pkgs, ... }:

with lib;
{
  nixpkgs.overlays = [
    (self: super: {
      jackett = pkgs.callPackage ./jackett { };
    })
  ];
}
