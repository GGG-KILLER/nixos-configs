{...}: {
  imports = [
    ./backup/restic.nix
    ./downloads
    ./gaming
    ./monitoring
    ./security
    ./cockpit.nix
    ./docker-registry.nix
    ./homarr.nix
    ./home-assistant.nix
    ./minio.nix
    ./nginx.nix
    ./openspeedtest.nix
  ];
}
