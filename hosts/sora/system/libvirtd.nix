{ ... }:
{
  virtualisation.spiceUSBRedirection.enable = true;

  # libvirtd
  virtualisation.libvirtd.enable = true;

  # TODO: check if OVMF removal needs any other updates.
  # virtualisation.libvirtd.qemu.ovmf.enable = true;
  # virtualisation.libvirtd.qemu.ovmf.packages = [
  #   (pkgs.OVMF.override {
  #     secureBoot = true;
  #     tpmSupport = true;
  #     msVarsTemplate = true;
  #   }).fd
  # ];

  virtualisation.libvirtd.qemu.swtpm.enable = true;
}
