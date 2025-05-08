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
    };

    serviceConfig = {
      DynamicUser = true;

      ExecStart = getExe self.packages.${system}.glorp;
      WorkingDirectory = "${self.packages.${system}.glorp}/lib/glorp";
      EnvironmentFile = config.age.secrets."glorp.env".path;

      # Hardening
      # IPAddressAllow = "192.168.1.1";
      # IPAddressDeny = "localhost multicast 192.168.0.0/24 172.16.0.0/24";
      LockPersonality = true;
      # MemoryDenyWriteExecute = true; # Figure out why this doesn't work. They should've solved this already.
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "full";
      RemoveIPC = true;
      RestrictAddressFamilies = "AF_UNIX AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@clock";
    };
  };
}
