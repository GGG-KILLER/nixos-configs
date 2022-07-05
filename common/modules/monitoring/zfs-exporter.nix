{ config, pkgs, lib, ... }:
with lib;
let

  cfg = config.modules.services.zfs-exporter;
in
{

  options.modules.services.zfs-exporter = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the zfs_exporter service.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-zfs-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        ExecStart = ''
          ${pkgs.local.zfs_exporter}/bin/zfs_exporter
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
