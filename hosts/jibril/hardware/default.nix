{ inputs, ... }:
{
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/skylake"
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-pc
    common-pc-ssd
  ]);

  # Enable hardware
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # I2C
  hardware.i2c.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
}
