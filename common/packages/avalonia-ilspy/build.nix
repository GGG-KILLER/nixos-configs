{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  avalonia-ilspy = pkgs.callPackage ./default.nix {};
}
