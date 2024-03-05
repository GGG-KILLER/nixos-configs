{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  kemono-dl = pkgs.callPackage ./default.nix {};
}
