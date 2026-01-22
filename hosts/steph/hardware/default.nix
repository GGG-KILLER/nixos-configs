{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [] ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel-kaby-lake
    common-pc
    common-pc-laptop
    common-pc-laptop-ssd
  ]);

  # Enable hardware
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Xbox Controller
  hardware.xone.enable = true;
  hardware.xpad-noone.enable = false;

  # Powertop Autotune
  powerManagement.powertop.enable = true;
}
