{...}: {
  imports = [
    ./exporters
    ./grafana.nix
    ./prometheus.nix
    ./smartd.nix
    ./zfs.nix
  ];
}
