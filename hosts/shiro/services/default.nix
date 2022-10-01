{...}: {
  imports = [
    ./monitoring
    ./backup/restic.nix
    ./docker-registry.nix
    ./nginx.nix
    ./pterodactyl.nix
    ./step-ca.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
