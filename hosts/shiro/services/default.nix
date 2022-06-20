{ ... }:

{
  imports = [
    ./monitoring
    ./backup/restic.nix
    ./downloader.nix
    ./nginx.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
