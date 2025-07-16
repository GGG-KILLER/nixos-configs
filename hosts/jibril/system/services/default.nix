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
    ./michi-site.nix
    #./n8n.nix
    ./nginx.nix
    ./openspeedtest.nix
  ];
}
