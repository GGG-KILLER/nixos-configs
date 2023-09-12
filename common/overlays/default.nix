{inputs, ...}: {
  imports = [
    ./local
    # ./ffmpeg-cuda-fix.nix
    # ./nixpkgs-review.nix
    ./prometheus-node-exporter.nix
    ./torch-with-cuda.nix
    ./virt-v2v.nix
    # "${inputs.mats-config}/common/overlays/mpv.nix"
  ];
}
