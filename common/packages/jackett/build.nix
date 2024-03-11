{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  jackett = pkgs.callPackage ./default.nix {};
}
