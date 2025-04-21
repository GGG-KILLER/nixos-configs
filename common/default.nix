{
  lib,
  liveCd ? false,
  ...
}:
{
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
    ./programs.nix
    ./time.nix
  ] ++ (lib.optionals (!liveCd) [ ./home-manager.nix ]);

  environment.pathsToLink = [ "/share/zsh" ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # TODO: Remove when home-assistant no longer uses deprecated openssl. Blocked on project-chip/connectedhomeip#25688
  ];
}
