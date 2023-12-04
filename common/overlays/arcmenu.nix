{lib, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      gnomeExtensions = lib.recursiveUpdate super.gnomeExtensions {arcmenu = super.callPackage ./arcmenu {};};
    })
  ];
}
