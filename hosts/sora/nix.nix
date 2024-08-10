{ ... }:
{
  nix.settings = {
    http-connections = 100;
    max-substitution-jobs = 64;
    keep-going = true;
    # max-jobs = "auto";
    use-cgroups = true;
    warn-dirty = false;
  };

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 3d";
  };
}
