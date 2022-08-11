# Thanks to @myaats for providing this to me
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.qbittorrent;
in {
  options.modules.services.qbittorrent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable qbittorrent service";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
    };
    user = mkOption {
      type = types.str;
      default = "qbittorrent";
    };
    group = mkOption {
      type = types.str;
      default = "qbittorrent";
    };
    web = {
      port = mkOption {
        type = types.port;
        default = 8081;
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "qbittorrent") {
      "${cfg.user}" = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.user == "qbittorrent") {
      "${cfg.group}" = {gid = null;};
    };

    systemd.services.qbittorrent = {
      after = ["network.target"];
      description = "qBittorrent Daemon";
      wantedBy = ["multi-user.target"];
      path = [pkgs.qbittorrent-nox];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
            --profile=${cfg.dataDir} \
            --webui-port=${toString cfg.web.port}
        '';
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        LimitNOFILE = 10240;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0770 ${cfg.user} ${cfg.group}"
    ];
  };
}
