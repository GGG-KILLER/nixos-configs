{inputs, ...}: {
  imports = [
    ./local
    ./nix.nix
    ./prometheus-node-exporter.nix
    ./torch.nix
    ./virt-v2v.nix
  ];
}
