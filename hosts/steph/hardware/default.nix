{ inputs, ... }:
{
  imports =
    [ ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      asus-battery
      common-cpu-amd
      common-cpu-amd-pstate
      common-cpu-amd-zenpower
      common-gpu-amd
      common-pc-laptop
      common-pc-laptop-ssd
    ]);

  # Limit battery
  hardware.asus.battery = {
    chargeUpto = 80;
    enableChargeUptoScript = true;
  };

  # Enable graphics
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Xbox Controller
  hardware.xone.enable = true;
  hardware.xpad-noone.enable = false;
}
