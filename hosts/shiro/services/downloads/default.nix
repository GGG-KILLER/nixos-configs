{ ... }:
{
  imports = [
    ./downloader.nix
    ./live-stream-dvr.nix
    # ./megasync.nix # TODO: Re-enable when Patreon subs restart
    ./sonarr.nix
  ];
}
