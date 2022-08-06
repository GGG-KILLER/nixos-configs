{...}: {
  # system.autoUpgrade.enable = true;

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 5d";
  };
}
