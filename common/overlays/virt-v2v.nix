{ ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      virt-v2v = super.callPackage ./virt-v2v { };
    })
  ];
}
