{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.ggg.users.service-users;
in
{
  options.ggg.users.service-users.enable = mkEnableOption "the shared data-members service accounts";

  config = mkIf cfg.enable {
    users.mutableUsers = lib.mkDefault false;

    users.users = {
      danbooru = {
        uid = 261;
        isSystemUser = true;
        group = "data-members";
      };
      downloader = {
        uid = 259;
        isSystemUser = true;
        group = "data-members";
      };
      file-browser = {
        uid = 262;
        isSystemUser = true;
        group = "data-members";
      };
      my-sonarr = {
        uid = 258;
        isSystemUser = true;
        group = "data-members";
      };
      my-torrent = {
        uid = 256;
        isSystemUser = true;
        group = "data-members";
      };
      streamer = {
        uid = 257;
        isSystemUser = true;
        group = "data-members";
        extraGroups = [
          "video"
          "render"
        ];
      };
      valheim = {
        uid = 260;
        isSystemUser = true;
        group = "data-members";
      };
    };
  };
}
