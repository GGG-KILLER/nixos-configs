{inputs, ...}: {
  imports = [
    ./local
    # ./ffmpeg-cuda-fix.nix
    ./prometheus-node-exporter.nix
    ./virt-v2v.nix
    # "${inputs.mats-config}/common/overlays/mpv.nix"
  ];
}
