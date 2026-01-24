{ config, ... }:
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

  ggg.caddy.enable = true;
  ggg.caddy.acme-url = "https://ca.lan:${toString config.jibril.ports.step-ca}/acme/acme/directory";
}
