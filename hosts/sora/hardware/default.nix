{ ... }:
{
  imports = [
    ./video.nix
    ./zfs.nix
  ];

  # I2C
  hardware.i2c.enable = true;

  # Firmware
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;

  # Corsair Keyboard
  hardware.ckb-next.enable = true;

  # Steam Controller
  hardware.xone.enable = true;
  hardware.steam-hardware.enable = true;

  # Open Tablet thingio
  hardware.opentabletdriver.enable = true;
}
