{ ... }:

{
  imports = [
    ./monitoring
    ./backup/restic.nix
    ./docker-registry.nix
    ./downloader.nix
    ./nginx.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
