{
  self,
  pkgs,
  system,
  ...
}: {
  imports = [
    ./commands
  ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      tmux
      yt-dlp
      aria
      step-cli
      self.packages.${system}.kemono-dl
      ffmpeg-full
    ];
  };
}
