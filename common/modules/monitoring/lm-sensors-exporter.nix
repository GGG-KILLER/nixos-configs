# Thanks to @myaats for providing this to me
{
  self,
  config,
  lib,
  system,
  ...
}:
with lib; let
  cfg = config.modules.services.lm-sensors-exporter;
in {
  options.modules.services.lm-sensors-exporter = {
    enable = mkEnableOption "Whether to enable the prometheus-lm-sensors-exporter service.";
    port = mkOption {
      type = types.port;
      default = 9255;
      description = lib.mdDoc ''
        Port to listen on.
      '';
    };
    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = lib.mdDoc ''
        Address to listen on.
      '';
    };
    user = mkOption {
      type = types.str;
      default = "lm-sensors-exporter";
      description = lib.mdDoc ''
        User name under which the lm-sensors exporter shall be run.
      '';
    };
    group = mkOption {
      type = types.str;
      default = "lm-sensors-exporter";
      description = lib.mdDoc ''
        Group under which the lm-sensors exporter shall be run.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services."prometheus-lm-sensors-exporter" = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = ''
          ${self.packages.${system}.lm-sensors-exporter}/bin/sensor-exporter \
            -web.listen-address ${cfg.listenAddress}:${toString cfg.port}
        '';
        Restart = mkDefault "always";
        PrivateTmp = mkDefault true;
        WorkingDirectory = mkDefault /tmp;
        DynamicUser = mkDefault true;
        User = mkDefault cfg.user;
        Group = cfg.group;
        # Hardening
        CapabilityBoundingSet = mkDefault [""];
        DeviceAllow = [""];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = mkDefault true;
        ProtectClock = mkDefault true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = mkDefault "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };
}
