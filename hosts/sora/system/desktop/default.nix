{ ... }:
{
  imports = [
    ./audio
    ./kde.nix
    ./rustdesk.nix
  ];

  # Flatpak
  services.flatpak.enable = true;
}
