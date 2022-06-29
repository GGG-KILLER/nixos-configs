{ config, pkgs, ... }:

{
  imports = [
    ./downloader.nix
    ./ggg.nix
    ./my-torrent.nix
    ./streamer.nix
    ./my-sonarr.nix
  ];

  users.mutableUsers = false;
}
