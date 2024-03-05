{pkgs, ...}: let
  kemono-dl = pkgs.callPackage ../../../../common/packages/kemono-dl {};
in {
  imports = [
    ./commands
  ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [tmux yt-dlp aria step-cli kemono-dl];
  };
}
