{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      chrome-remote-desktop = super.callPackage ./chrome-remote-desktop { };
    })
  ];
}
