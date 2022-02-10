{ ... }:

{
  imports = [
    ./groups
    ./modules
    ./nixos
    ./secrets
    ./users
    ./console.nix
    ./i18n.nix
    ./time.nix
  ];
}
