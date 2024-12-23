{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./media/danbooru
    # ./monitoring # TODO: Re-enable when job again.
    # ./nix-pr-tracker # TODO: Re-enable when job again.
    ./security
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
