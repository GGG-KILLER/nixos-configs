{...}: {
  imports = [
    ./backup/restic.nix
    ./download/megasync.nix
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
