{ ... }:

{
  system.autoUpgrade.enable = true;

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 15d";
  };

  # Auto Optimise the Store
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
  };
}
