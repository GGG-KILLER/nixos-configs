{ ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      rclone = super.callPackage ./rclone { };
    })
  ];
}
