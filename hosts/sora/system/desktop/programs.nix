{
  self,
  system,
  pkgs,
  config,
  ...
}:
let
  inherit (self.packages.${system}) vivaldi-wayland;
in
{
  environment.systemPackages = with pkgs; [
    # Games
    r2modman
    lutris
    (makeAutostartItem {
      name = "steam";
      package = config.programs.steam.package;
    })

    # Hardware
    nvtopPackages.nvidia

    # Web
    vivaldi-wayland

    # Misc
    localsend
    bleachbit
  ];

  # Needed for flatpak
  services.flatpak.enable = true;

  # Steam
  programs.gamemode.enable = true;
  programs.steam.enable = true;
  programs.steam.extraPackages = with pkgs; [
    (mangohud.override {
      nvidiaSupport = true;
    })
  ];
  programs.steam.package = pkgs.steam.override {
    extraEnv = {
      MANGOHUD = true;
    };
  };
  programs.steam.extest.enable = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
  programs.steam.protontricks.enable = true;
  programs.steam.remotePlay.openFirewall = true;
}
