{inputs, ...}: {
  imports = [
    ./local
    ./prometheus-node-exporter.nix
    ./torch.nix
    ./virt-v2v.nix
  ];
}
