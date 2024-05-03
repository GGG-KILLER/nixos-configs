{...}: {
  imports = [
    ./backup/restic.nix
    ./downloads
    ./gaming
    ./monitoring
    ./security
    ./docker-registry.nix
    ./home-assistant.nix
    ./minio.nix
    ./nginx.nix
    ./openspeedtest.nix
  ];
}
