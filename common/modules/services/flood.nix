# Thanks to @myaats for providing this to me
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  floodCfg = config.modules.services.flood;
  qbittorrentCfg = config.modules.services.qbittorrent;
in {
  options.modules.services.flood = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable flood service.";
    };
    rundir = mkOption {
      type = types.path;
      description = "the path where flood will save its data do.";
    };
    auth = mkOption {
      type = types.enum ["default" "none"];
      description = "the auth method that flood should use.";
      default = "none";
    };
    allowedpath = mkOption {
      type = with types; nullOr (listOf path);
      description = "the paths flood is allowed to access.";
      default = null;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.flood;
      defaultText = literalExpression "pkgs.flood";
      description = "the package that contains the flood binary.";
    };
    web = {
      port = mkOption {
        type = types.port;
        default = 8085;
      };
    };
    qbittorrent = {
      url = mkOption {
        type = types.str;
      };
      user = mkOption {
        type = types.str;
      };
      password = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf floodCfg.enable {
    assertions = [
      {
        assertion = qbittorrentCfg.enable;
        message = "qBitTorrent must be enabled to enable Flood";
      }
    ];

    systemd.services.flood = let
      allowedpaths =
        if floodCfg.allowedpath == null
        then ""
        else concatMapStrings (p: "--allowedpath \"${p}\" ") floodCfg.allowedpath;
    in {
      after = ["network.target" "qbittorrent.service"];
      description = "Flood UI";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = ''
          ${floodCfg.package}/bin/flood \
            -p${toString floodCfg.web.port}\
            --host 0.0.0.0 \
            --rundir "${floodCfg.rundir}" \
            --auth "${floodCfg.auth}" \
            --qburl "${floodCfg.qbittorrent.url}" \
            --qbuser "${floodCfg.qbittorrent.user}" \
            --qbpass "${floodCfg.qbittorrent.password}" \
            ${allowedpaths}
        '';
        Restart = "on-success";
        User = qbittorrentCfg.user;
        Group = qbittorrentCfg.group;
      };
      environment = {
        NODE_ENV = "production";
      };
    };
  };
}
