{inputs, ...}: {
  imports = [
    ./local
    ./prometheus-node-exporter.nix
    ./virt-v2v.nix
    # "${inputs.mats-config}/common/overlays/mpv.nix"
  ];
}
