{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  git-credential-manager = pkgs.callPackage ./default.nix {};
}
