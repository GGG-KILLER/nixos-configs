{ pkgs, ... }:
{
  virtualisation.spiceUSBRedirection.enable = true;

  # libvirtd
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      packages = [
        (pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
          msVarsTemplate = true;
        }).fd
      ];
    };
    qemu.swtpm.enable = true;
  };
}
