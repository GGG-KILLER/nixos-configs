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

    wireplumber.enable = false;
    media-session.enable = true;
    media-session.config.alsa-monitor = {
      rules = [
        {
          matches = [{"device.name" = "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00";}];
          actions = {
            update-props = {
              #"api.alsa.soft-mixer" = true;
              "api.alsa.ignore-dB" = true;
              "api.alsa.volume" = "ignore";
              "api.alsa.volume-limit" = 0.01;
            };
          };
        }
      ];
    };
  };
}
