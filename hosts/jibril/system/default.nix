{ ... }:
{
  imports = [
    ./services
    ./networking.nix
    ./virtualisation.nix
  ];

  # Automatic garbage collect
  nix.gc = {
    automatic = true;
    dates = "00:00";
    options = "--delete-older-than 5d";
  };
}
