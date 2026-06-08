{ lib, pkgs, ... }:
{
  systemd.services.hd-idle = {
    description = "hd-idle - spin down idle hard disks";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.hd-idle} -i ${toString (5 * 60)} -c ata -l /var/log/hd-idle/hd-idle.log";
      Restart = "always";

      # ProtectSystem=strict makes /var/log read-only, which made hd-idle crash
      # (log.Fatal) the first time it logged a spindown. LogsDirectory creates a
      # writable /var/log/hd-idle owned by the DynamicUser.
      LogsDirectory = "hd-idle";

      # Light Hardening
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
      DynamicUser = true;
      User = "hd-idle";
      Group = "hd-idle";

      # Advanced Hardening
      AmbientCapabilities = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];
      CapabilityBoundingSet = [
        "CAP_SYS_RAWIO"
        "CAP_SYS_ADMIN"
      ];
      DeviceAllow = [
        "block-blkext rw"
        "block-sd rw"
        "char-nvme rw"
      ];
      DevicePolicy = "closed";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [ ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SupplementaryGroups = [ "disk" ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0077";
    };
  };
}
