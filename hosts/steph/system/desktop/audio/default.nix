{ pkgs, ... }:
{
  # Disable pulseaudio
  services.pulseaudio.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;

  # Enable pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Fix audio crackling during high CPU workloads and/or gaming while screensharing and voice chatting
    extraConfig.pipewire."99-quantum" = {
      "context.properties" = {
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512; # don't let games negotiate down (which is what causes the crackling)
      };
    };

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
