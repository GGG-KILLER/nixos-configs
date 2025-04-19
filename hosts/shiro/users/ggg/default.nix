{
  self,
  pkgs,
  system,
  ...
}:
{
  imports = [ ./commands ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      tmux
      yt-dlp
      aria
      #step-cli # TODO: Uncomment if it's still used and NixOS/nixpkgs#301623 has hit unstable.
      #self.packages.${system}.kemono-dl # TODO: Uncomment after install.
      ffmpeg
    ];
  };
}
