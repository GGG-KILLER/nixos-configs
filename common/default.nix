{ ... }:
{
  imports = [
    ./groups
    ./modules
    ./overlays
    ./secrets
    ./users
    ./boot.nix
    ./home-manager.nix
    ./nix.nix
    ./programs.nix
    ./sudo.nix
  ];

  environment.pathsToLink = [ "/share/zsh" ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # TODO: Remove when home-assistant no longer uses deprecated openssl. Blocked on project-chip/connectedhomeip#25688
  ];
}
