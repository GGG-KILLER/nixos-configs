{lib, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      gnomeExtensions = lib.recursiveUpdate super.gnomeExtensions {arcMenu = super.callPackage ./arcmenu {};};
    })
  ];
}
