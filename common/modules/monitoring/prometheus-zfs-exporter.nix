# Thanks to @myaats for providing this to me
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.zfs-exporter;
in {
  options.modules.services.zfs-exporter = {
    enable = mkEnableOption "Whether to enable the prometheus-zfs-exporter service.";
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-zfs-exporter" = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Restart = "always";
        ExecStart = ''
          ${pkgs.prometheus-zfs-exporter}/bin/zfs_exporter
        '';
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        DynamicUser = true;
        # Hardening
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
      };
    };
  };
}
