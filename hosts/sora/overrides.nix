{
  inputs,
  system,
  ...
}: let
  nixpkgs-stable = import inputs.nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  nixpkgs.overlays = [
  ];
}
