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
    ./jellyfin.nix
    ./nginx.nix
    ./zfs.nix
  ];
}
