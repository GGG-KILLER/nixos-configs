{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./monitoring
    ./btrfs.nix
    ./cockpit.nix
    ./minio.nix
    ./nginx.nix
    ./zfs.nix
  ];
}
