{ ... }:
{
  imports = [
    ./lm-sensors-exporter.nix
    ./nginx.nix
    ./qbittorrent.nix
  ];
}
