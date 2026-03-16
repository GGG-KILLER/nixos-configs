{ ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      # Low Latency BLE
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
      # Connect loop
      ControllerMode = "dual";
      JustWorksRepairing = "confirm";
    };
  };

  hardware.xpadneo.enable = true;
  hardware.xpadneo.settings = {
    # disable_deadzones:
    #   0 = enables standard behavior to be compatible with joydev expectations
    #   1 = enables raw passthrough of axis values without dead zones for high-precision use with modern Wine/Proton or other games implementing circular deadzones
    disable_deadzones = 1;
    # disable_shift_mode:
    #   0 = Xbox logo button will be used as shift
    #   1 = will pass through the Xbox logo button as is
    disable_shift_mode = 1;
  };
}
