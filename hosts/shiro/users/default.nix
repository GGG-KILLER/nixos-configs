{
  self,
  pkgs,
  system,
  ...
}:
let
  inherit (self.packages.${system}) kemono-dl find-ata;
in
{
  imports = [
    ./ggg.nix
  ];

  home-manager.users.ggg = {
    home.packages = with pkgs; [
      aria2
      ffmpeg
      find-ata
      gallery-dl
      kemono-dl
      mprocs
      #step-cli # TODO: Uncomment if it's still used and NixOS/nixpkgs#301623 has hit unstable.
      tmux
      yt-dlp
    ];
  };
}
