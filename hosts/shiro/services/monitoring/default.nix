{ ... }:
{
  imports = [
    ./exporters
    ./netprobe
    ./cadvisor.nix
    ./grafana.nix
    ./prometheus.nix
    ./smartd.nix
    ./statping.nix
    ./zfs.nix
  ];
}
