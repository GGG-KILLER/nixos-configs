{ ... }:
{
  imports = [
    # ./downloader.nix # TODO: Re-enable when job again.
    ./live-stream-dvr.nix
    # ./megasync.nix # TODO: Re-enable when Patreon subs restart
    ./sonarr.nix
  ];
}
