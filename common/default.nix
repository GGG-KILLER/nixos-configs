{...}: {
  imports = [
    ./groups
    ./modules
    ./overlays
    ./secrets
    ./users
    ./boot.nix
    ./console.nix
    ./home-manager.nix
    ./i18n.nix
    ./nix.nix
    ./pki.nix
    ./time.nix
  ];

  environment.pathsToLink = ["/share/zsh"];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1t"
  ];
}
