{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./monitoring
    ./btrfs.nix
    ./cockpit.nix
    ./hd-idle.nix
    ./minio.nix
    ./nginx.nix
    ./zfs.nix
  ];
}
