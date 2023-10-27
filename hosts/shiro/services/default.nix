{...}: {
  imports = [
    ./gaming
    ./monitoring
    ./backup/restic.nix
    ./docker-registry.nix
    ./minio.nix
    ./nginx.nix
    ./smartd.nix
    ./step-ca.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
