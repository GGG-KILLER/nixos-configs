{ config, pkgs, ... }:

{
  imports = [
    ./ggg.nix
    ./my-torrent.nix
    ./streamer.nix
    ./my-sonarr.nix
  ];

  users.mutableUsers = false;
}
