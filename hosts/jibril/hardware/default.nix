{ inputs, pkgs, ... }:
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
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.extraPackages = with pkgs; [
    # i5-6500T / HD Graphics 530 (Skylake, Gen9): VA-API only.
    # No QSV runtime here: vpl-gpu-rt only targets 11th-gen+ (Xe/ARC), and the
    # Skylake-era alternative, intel-media-sdk, is deprecated with unpatched CVEs.
    intel-media-driver # VA-API (iHD) userspace

    # Optional (compute / tooling):
    intel-compute-runtime # OpenCL (NEO) + Level Zero
    # NOTE: 'intel-ocl' also exists as a legacy package; not recommended.
    # libvdpau-va-gl       # Only if you must run VDPAU-only apps
  ];

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
