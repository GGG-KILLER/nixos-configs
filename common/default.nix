{ ... }:

{
  imports = [
    ./groups
    ./modules
    ./nixos
    ./overlays
    ./secrets
    ./users
    ./boot.nix
    ./console.nix
    ./flakes.nix
    ./i18n.nix
    ./time.nix
  ];
}
