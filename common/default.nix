{ ... }:

{
  imports = [
    ./groups
    ./modules
    ./nixos
    ./overlays
    ./secrets
    ./users
    ./console.nix
    ./i18n.nix
    ./time.nix
  ];
}
