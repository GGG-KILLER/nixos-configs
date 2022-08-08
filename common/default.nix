{...}: {
  imports = [
    ./groups
    ./modules
    ./overlays
    ./secrets
    ./users
    ./boot.nix
    ./console.nix
    ./i18n.nix
    ./nix.nix
    ./pki.nix
    ./time.nix
  ];
}
