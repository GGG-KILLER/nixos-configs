{...}: {
  imports = [
    ./backup/restic.nix
    ./databases
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
