{ ... }:

{
  imports = [
    ./monitoring
    ./backup/restic.nix
    ./docker-registry.nix
    ./nginx.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
