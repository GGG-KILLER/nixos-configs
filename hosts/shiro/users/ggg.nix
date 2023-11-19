{
  config,
  system,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.ggg = {
    home.packages = with pkgs; [tmux yt-dlp aria];
  };
}
