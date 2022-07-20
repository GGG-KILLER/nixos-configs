{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  rclone = pkgs.callPackage ./default.nix {};
}
