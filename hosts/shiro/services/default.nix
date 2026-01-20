{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./downloads
    ./monitoring
    ./btrfs.nix
    ./cockpit.nix
    ./file-browser.nix
    ./hd-idle.nix
    ./minio.nix
    ./nginx.nix
    ./zfs.nix
  ];
}
