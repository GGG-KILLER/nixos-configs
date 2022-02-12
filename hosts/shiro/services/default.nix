{ ... }:

{
  imports = [
    ./monitoring
    ./backup/restic.nix
    ./nginx.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
