{...}: {
  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };

  environment.etc."wireplumber/main.lua.d/51-disable-devices.lua".source = ./51-disable-devices.lua;
  environment.etc."wireplumber/main.lua.d/99-fix-bad-headset.lua".source = ./99-fix-bad-headset.lua;
}
