{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe';
in
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-streaming) {
    # Jellyfin
    services.jellyfin = {
      # enable = true; # TODO: Uncomment once NixOS/nixpkgs#149715 gets merged.
      user = "streamer";
      group = "data-members";
      package = pkgs.jellyfin;
    };

    systemd.packages = [ pkgs.jellyfin ];
    systemd.services.jellyfin =
      let
        cfg = config.services.jellyfin;
      in
      {
        after = [
          "network.target"
          "storage-animu.mount"
          "storage-etc.mount"
          "storage-h.mount"
          "storage-series.mount"
        ];
        requires = [
          "storage-animu.mount"
          "storage-etc.mount"
          "storage-h.mount"
          "storage-series.mount"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = rec {
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "jellyfin";
          CacheDirectory = "jellyfin";
          ExecStart = "${getExe' cfg.package "jellyfin"} --datadir '/var/lib/${StateDirectory}' --cachedir '/var/cache/${CacheDirectory}'";
          Restart = "always";
        };
      };

    environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

    services.caddy.virtualHosts."http://jellyfin.lan, https://jellyfin.lan".extraConfig =
      "reverse_proxy http://127.0.0.1:8096";
  };
}
