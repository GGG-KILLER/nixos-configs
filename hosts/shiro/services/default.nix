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
    ./nginx.nix
    ./zfs.nix
  ];
}
