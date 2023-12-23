{inputs, ...}: {
  imports = [
    ./local
    ./nix.nix
    ./prometheus-node-exporter.nix
    ./r2modman.nix
    ./torch.nix
    ./virt-v2v.nix
  ];
}
