{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./media/danbooru
    ./monitoring
    ./nix-pr-tracker
    ./security
    ./cloudflared.nix
    ./cockpit.nix
    ./docker-registry.nix
    ./home-assistant.nix
    ./minio.nix
    ./nginx.nix
    ./openspeedtest.nix
    ./zfs.nix
  ];
}
