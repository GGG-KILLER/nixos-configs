{
  self,
  lib,
  system,
  config,
  ...
}:
let
  inherit (lib) getExe;
in
{
  systemd.services.glorp = {
    wantedBy = [ "network-online.target" ];

    environment = {
      # Environment settings
      DOTNET_ENVIRONMENT = "Production";

      HOME = "%C/glorp";
    };

    serviceConfig = {
      ExecStart = getExe self.packages.${system}.glorp;
      WorkingDirectory = "${self.packages.${system}.glorp}/lib/glorp";
      EnvironmentFile = config.age.secrets."glorp.env".path;
      CacheDirectory = "glorp";

      # Hardening
      SystemCallFilter = [
        "~@swap @resources @reboot @raw-io @privileged @obsolete @mount @module @debug @cpu-emulation @clock"
        "sched_setaffinity sched_setscheduler"
      ];
      RemoveIPC = true;
      DynamicUser = true;
      RestrictRealtime = true;
      NoNewPrivileges = true;
      SystemCallArchitectures = "native";
      CapabilityBoundingSet = ""; # No capabilities needed.
      # MemoryDenyWriteExecute = true; # Figure out why this doesn't work. They should've solved this already.
      RestrictAddressFamilies = "AF_UNIX AF_INET";
      ProtectSystem = "full";
      PrivateTmp = true;
      ProtectHome = true;
      PrivateDevices = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      # PrivateNetwork = true; # Needs access to the network.
      PrivateUsers = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      PrivateMounts = true;
      RestrictNamespaces = true;
      ProtectHostname = true;
      LockPersonality = true;
      ProtectKernelTunables = true;
      RestrictSUIDSGID = true;
      # IPAddressAllow = "192.168.1.1";
      IPAddressDeny = "localhost multicast 10.0.0.0/8 172.16.0.0/24";
    };
  };
}
