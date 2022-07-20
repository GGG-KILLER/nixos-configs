{...}: {
  imports = [
    ./groups
    ./modules
    ./nixos
    ./overlays
    ./secrets
    ./users
    ./boot.nix
    ./console.nix
    ./i18n.nix
    ./pki.nix
    ./time.nix
  ];
}
