{...}: {
  # Limit to 10 cores so I don't have a totally unresponsive system.
  nix.settings = {
    cores = 11;
    max-jobs = 11;
  };

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 3d";
  };
}
