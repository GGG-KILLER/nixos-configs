{
  pkgs,
  inputs,
  system,
  ...
}:
{
  # udev rules for the Gowin USB programmer cable (FT2232-based). Adapted from
  # the rules shipped with the IDE, pointing at a real bash since NixOS has no
  # /bin/bash.
  services.udev.extraRules = ''
    ACTION=="add", ATTR{idVendor}=="33aa", ATTR{idProduct}=="0120", MODE:="666"

    # Detach the kernel ftdi_sio driver so the programmer can claim the device.
    ATTRS{idVendor}=="0403", ATTR{idProduct}=="6014", MODE:="666", PROGRAM="${pkgs.bash}/bin/bash -c 'echo -n $id:1.1 > /sys/bus/usb/drivers/ftdi_sio/unbind'"
    ATTRS{idVendor}=="0403", ATTR{idProduct}=="6014", MODE:="666", PROGRAM="${pkgs.bash}/bin/bash -c 'echo -n $id:1.0 > /sys/bus/usb/drivers/ftdi_sio/unbind'"
  '';

  home-manager.users.ggg = {
    home.packages =
      (with pkgs; [
        python314Packages.apycula
        nextpnr
        openfpgaloader
      ])
      ++ [
        inputs.gowin-eda.packages.${system}.default
      ];
  };
}
