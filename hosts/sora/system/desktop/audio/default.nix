{ pkgs, ... }:
{
  # rtkit is optional but recommended
  security.rtkit.enable = true;

  # Enable pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.linkFarm "sora-wireplumber-configs" {
          "share/wireplumber/main.lua.d/51-disable-devices.lua" = ./51-disable-devices.lua;
          "share/wireplumber/main.lua.d/99-fix-bad-headset.lua" = ./99-fix-bad-headset.lua;
        })
      ];
    };
  };
}
