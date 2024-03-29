{...}: {
  imports = [
    ./backup/restic.nix
    ./gaming
    ./monitoring
    ./security
    ./docker-registry.nix
    ./minio.nix
    ./nginx.nix
  ];
}
