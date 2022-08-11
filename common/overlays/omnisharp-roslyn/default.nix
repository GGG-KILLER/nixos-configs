{
  pkgs ?
    import <nixpkgs> {
      config = {allowUnfree = true;};
      overlays = [
        (builtins.head (import ../dotnet-combine.nix {}).nixpkgs.overlays)
        (builtins.head (import ../dotnet-7.0.nix {inputs.nixpkgs = <nixpkgs>;}).nixpkgs.overlays)
      ];
    },
}: {
  omnisharp-roslyn = pkgs.callPackage ./package.nix {};
}
