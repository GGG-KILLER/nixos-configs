{pkgs, ...}: {
  ##
  # AMD Driver
  ##
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelParams = ["radeon.si_support=0" "amdgpu.si_support=1"];
  services.xserver.videoDrivers = ["amdgpu"];

  ##
  # OpenGL
  ##
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      ##
      # VAAPI
      ##
      vaapiVdpau
      libvdpau-va-gl
      ##
      # Vulkan
      ##
      amdvlk
    ];
  };

  ##
  # Vulkan
  ##
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  # For 32 bit applications
  # Only available on unstable
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];
}
