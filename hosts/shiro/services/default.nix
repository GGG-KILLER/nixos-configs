{...}: {
  imports = [
    ./backup/restic.nix
    ./gaming
    ./monitoring
    ./security
    ./docker-registry.nix
    ./home-assistant.nix
    ./minio.nix
    ./nginx.nix
  ];
}
