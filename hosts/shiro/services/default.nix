{ ... }:

{
  imports = [
    ./backup/restic.nix
    ./monitoring.nix
    ./nginx.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
