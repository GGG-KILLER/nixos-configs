{ ... }:
{
  imports = [
    ./lm-sensors-exporter.nix
    ./node-exporter-smartmon.nix
  ];
}
