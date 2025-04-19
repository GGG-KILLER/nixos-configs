{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./media/danbooru
    ./monitoring
    # ./nix-pr-tracker # TODO: Re-enable when job again.
    ./security
    ./btrfs.nix
    ./cloudflared.nix
    ./cockpit.nix
    ./docker-registry.nix
    ./home-assistant.nix
    # ./minio.nix # TODO: Re-enable when job again.
    ./nginx.nix
    ./openspeedtest.nix
    ./zfs.nix
  ];
}
