{ ... }:
{
  nixpkgs.overlays = [
    (self: super: { prometheus-node-exporter = super.callPackage ./prometheus-node-exporter { }; })
  ];
}
