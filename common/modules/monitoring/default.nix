{...}: {
  imports = [
    ./node-exporter-smartmon.nix
    ./prometheus-zfs-exporter.nix
  ];
}
