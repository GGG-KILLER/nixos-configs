{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./media
    ./monitoring
    ./security
    ./bookstack.nix
    ./btrfs.nix
    ./cockpit.nix
    ./docker-registry.nix
    ./glorp.nix
    ./home-assistant.nix
    ./postgres.nix
  ];

  # Enable Caddy
  ggg.caddy.enable = true;
  #   we don't need these because we're the acme server
  ggg.caddy.email = null;
  ggg.caddy.acme-url = null;
}
