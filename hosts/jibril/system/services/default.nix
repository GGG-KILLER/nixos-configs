{ ... }:
{
  imports = [
    ./backup/restic.nix
    ./monitoring
    ./security
    ./btrfs.nix
    ./cloudflared.nix
    ./cockpit.nix
    ./docker-registry.nix
    ./glorp.nix
    ./home-assistant.nix
    #./n8n.nix
    ./openspeedtest.nix
    ./postgres.nix
  ];

  # Enable Caddy
  ggg.caddy.enable = true;
  #   we don't need these because we're the acme server
  ggg.caddy.email = null;
  ggg.caddy.acme-url = null;
}
