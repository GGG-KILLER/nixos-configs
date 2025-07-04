{
  inputs,
  lib,
  config,
  ...
}:
{
  imports =
    [
      # ./video.nix
      ./zfs.nix

      "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
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
  hardware.cpu.amd.updateMicrocode = true;

  # Corsair Keyboard
  hardware.ckb-next.enable = true;

  # Steam Controller
  hardware.xone.enable = true;
  hardware.steam-hardware.enable = true;

  # Open Tablet thingio
  hardware.opentabletdriver.enable = true;
}
