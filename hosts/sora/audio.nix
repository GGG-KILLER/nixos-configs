{...}: {
  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
    media-session.enable = false;
  };

  environment.etc."wireplumber/main.lua.d/99-fix-bad-headset.lua" = {
    text = ''
      local rule = {
          matches = {
            {
              { "device.name", "matches", "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00" },
            },
          },
          apply_properties = {
            ["api.alsa.ignore-dB"] = true,
            ["api.alsa.volume"] = "ignore",
            ["api.alsa.volume-limit"] = 0.01,
          }
      }

      table.insert(alsa_monitor.rules, rule)
    '';
  };
}
