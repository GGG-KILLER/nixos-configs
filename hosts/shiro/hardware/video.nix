{ inputs, config, ... }:
{
  imports = [
    "${inputs.nixos-hardware}/common/gpu/nvidia/pascal"
  ]
  ++ (with inputs.nixos-hardware.nixosModules; [
    common-gpu-nvidia-nonprime
  ]);

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.nvidia = {
    # TODO: when 590 comes out, remove this fallback. 580 is the last version to support the Quadro P400.
    package =
      config.boot.kernelPackages.nvidiaPackages.legacy_580
        or config.boot.kernelPackages.nvidiaPackages.stable;

    # NOTE: open kernel module does not work with the Quadro P400
    open = false;

    # don't add nvidia-settings package to system packages since we don't have a desktop environment.
    nvidiaSettings = false;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };
}
