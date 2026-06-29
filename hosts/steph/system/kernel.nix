{ pkgs, ... }:
{
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Scheduler
  services.scx.enable = true;
  services.scx.package = pkgs.scx.rustscheds;
  services.scx.scheduler = "scx_bpfland";
  services.scx.extraArgs = [ ];
}
