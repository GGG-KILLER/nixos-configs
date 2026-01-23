{
  self,
  system,
  pkgs,
  ...
}:
let
  inherit (self.packages.${system}) vivaldi-wayland;
in
{
  environment.systemPackages = with pkgs; [
    # Games
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk11
        jdk17
        jdk21
      ];
    })
    r2modman
    lutris

    # Hardware
    openrgb
    nvtopPackages.nvidia

    # Web
    vivaldi-wayland

    # Misc
    localsend
    bleachbit
  ];

  # Needed for flatpak
  services.flatpak.enable = true;

  programs.gamemode.enable = true;
}
