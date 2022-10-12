{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./ggg
    ./downloader.nix
    ./my-torrent.nix
    ./streamer.nix
    ./my-sonarr.nix
  ];

  users.mutableUsers = false;
}
