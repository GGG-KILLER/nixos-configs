{inputs, ...}: {
  imports = [
    ./local
    ./arcmenu.nix # TODO: Remove when NixOS/nixpkgs#270142 lands on unstable
    ./nix.nix
    ./prometheus-node-exporter.nix
    ./r2modman.nix
    ./torch.nix
    ./virt-v2v.nix
  ];
}
