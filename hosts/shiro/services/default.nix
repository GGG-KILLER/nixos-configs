{...}: {
  imports = [
    ./gaming
    ./monitoring
    ./backup/restic.nix
    ./docker-registry.nix
    ./nginx.nix
    # ./pterodactyl.nix
    ./smartd.nix
    ./step-ca.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
