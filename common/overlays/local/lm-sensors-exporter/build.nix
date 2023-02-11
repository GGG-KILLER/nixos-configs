{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
    },
}: {
  lm-sensors-exporter = pkgs.callPackage ./default.nix {};
}
