{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
    ./zfs.nix
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-pstate
    common-cpu-amd-zenpower
    common-gpu-nvidia-nonprime
    common-pc
    common-pc-ssd
  ]);

  # Enable hardware
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Pick specific nvidia driver
  hardware.nvidia.package =
    let
      stableDriver = config.boot.kernelPackages.nvidiaPackages.stable;
      unstableDriver = config.boot.kernelPackages.nvidiaPackages.beta;
    in
    if (lib.versionOlder unstableDriver.version stableDriver.version) then
      stableDriver
    else
      unstableDriver;

  # I2C
  hardware.i2c.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Xbox Controller
  hardware.xone.enable = true;
  hardware.xpad-noone.enable = false;
}
