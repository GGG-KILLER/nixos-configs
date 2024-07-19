{pkgs, ...}: {
  # Enable sound.
  hardware.pulseaudio.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.runCommand "wireplumber-configs" {} ''
          mkdir -p "$out/share/wireplumber/main.lua.d/"
          cp -t "$out/share/wireplumber/main.lua.d/" "${./51-disable-devices.lua}" "${./99-fix-bad-headset.lua}"
        '')
      ];
    };
  };
}
