{ ... }:
{
  imports = [
    ./exporters
    ./netprobe
    ./grafana.nix
    ./prometheus.nix
    ./smartd.nix
    ./uptime-kuma.nix
  ];
}
