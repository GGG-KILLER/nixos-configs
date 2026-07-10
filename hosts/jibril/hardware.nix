{ inputs, ... }:
{
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/coffee-lake"
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-pc
    common-pc-ssd
  ]);

  # Enable hardware
  # NOTE: the coffee-lake nixos-hardware module (imported above) already sets
  # `hardware.intelgpu.vaapiDriver = "intel-media-driver"`, which makes it
  # auto-add intel-media-driver + intel-compute-runtime-legacy1 (the
  # Gen8-11-appropriate variant) via hardware.graphics.extraPackages. Adding
  # our own intel-media-driver/intel-compute-runtime here (as jibril's
  # skylake-based hardware.nix does) would collide with those — skylake
  # doesn't hit this because it uses vaapiDriver = "intel-vaapi-driver",
  # which never triggers that auto-add.
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "modesetting" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Prefer the modern iHD backend
    # VDPAU_DRIVER = "va_gl";      # Only if using libvdpau-va-gl
  };

  # I2C
  hardware.i2c.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
}
