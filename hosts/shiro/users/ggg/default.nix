{
  config,
  system,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./commands
  ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [tmux yt-dlp aria step-cli];
  };
}
