{ lib, pkgs, ... }:

with lib;
let
  jsonFormat = pkgs.formats.json { };
in
{
  home-manager.users.ggg = {
    xdg.configFile."jellyfin-mpv-shim/conf.json".text = builtins.toJSON {
      mpv_ext = true;
      mpv_ext_path = "${pkgs.mpv}/bin/mpv";
    };

    systemd.user.services.jellyfin-mpv-shim.serviceConfig.ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim";
  };
}
