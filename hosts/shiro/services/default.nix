{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./databases
    ./downloads
    ./gaming
    ./media/danbooru
    ./monitoring
    ./nix-pr-tracker
    ./security
    ./cloudflared.nix
    ./cockpit.nix
    ./docker-registry.nix
    # ./homarr.nix
    ./home-assistant.nix
    ./minio.nix
    ./nginx.nix
    ./openspeedtest.nix
    ./zfs.nix
  ];
}
