{ lib, pkgs, ... }:

with lib;
let
  jsonFormat = pkgs.formats.json { };
in
{
  home-manager.users.ggg = {
    xdg.configFile."jellyfin-mpv-shim/conf.json" = {
      source = jsonFormat.generate "conf.json" {
        mpv_ext = true;
        mpv_ext_path = "${pkgs.mpv}/bin/mpv";
      };
    };

    systemd.user.services.jellyfin-mpv-shim = {
      Unit = {
        Description = "Jellyfin mpv shim";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = { ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim"; };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
