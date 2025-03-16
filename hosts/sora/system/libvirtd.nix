{ pkgs, ... }:
{
  virtualisation.spiceUSBRedirection.enable = true;

  # libvirtd
  virtualisation.libvirtd.enable = true;

  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  virtualisation.libvirtd.qemu.runAsRoot = true;

  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [
    (pkgs.OVMF.override {
      secureBoot = true;
      tpmSupport = true;
      msVarsTemplate = true;
    }).fd
  ];

  virtualisation.libvirtd.qemu.swtpm.enable = true;
}
