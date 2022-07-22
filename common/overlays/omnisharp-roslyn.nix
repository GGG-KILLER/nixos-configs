{...}: {
  nixpkgs.overlays = [
    (self: super: {
      omnisharp-roslyn = super.callPackage ./omnisharp-roslyn {};
    })
  ];
}
