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
      self.packages.${system}.yt-dlp
      aria
      step-cli
      self.packages.${system}.kemono-dl
      self.packages.${system}.ffmpeg-full
    ];
  };
}
