{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      local.zfs_exporter = pkgs.callPackage ./zfs_exporter { };
    })
  ];
}
