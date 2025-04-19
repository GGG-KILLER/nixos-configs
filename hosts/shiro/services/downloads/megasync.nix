{
  self,
  lib,
  system,
  ...
}:
let
  inherit (lib) getExe;
in
{
  systemd.services.megasync = {
    wantedBy = [ "network-online.target" ];
    environment = {
      # Enable tiered compilation
      DOTNET_TieredCompilation = "1";
      DOTNET_TieredPGO = "1";
      DOTNET_TC_QuickJitForLoops = "1";
      DOTNET_TC_PartialCompilation = "1";

      # Profiling needed for PGO
      DOTNET_JitClassProfiling = "1";
      DOTNET_JitDelegateProfiling = "1";
      DOTNET_JitVTableProfiling = "1";
      DOTNET_JitEdgeProfiling = "1";

      # PGO optimizations
      DOTNET_JitEnableGuardedDevirtualization = "1";
      DOTNET_JitInlinePolicyProfile = "1";

      # Enable OSR
      DOTNET_TC_OnStackReplacement = "1";

      # Other JIT toggles
      DOTNET_JitObjectStackAllocation = "1";

      # Environment settings
      ASPNETCORE_ENVIRONMENT = "Production";
      ASPNETCORE_URLS = "http://unix:/run/mega-sync/mega-sync.socket";

      ConnectionStrings__SQLite = "Data Source=/var/lib/mega-sync/database.sqlite3";
    };

    serviceConfig = {
      User = "mega-sync";
      Group = "data-members";
      UMask = "011"; # Allow other users to write to files.

      WorkingDirectory = "${self.packages.${system}.mega-sync}/lib/MegaSync";
      RuntimeDirectory = "mega-sync";
      StateDirectory = "mega-sync";

      ExecStart = getExe self.packages.${system}.mega-sync;

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
      ProtectProc = true;
      ProtectSystem = "full";
      BindPaths = "/storage/h /storage/etc";
      RemoveIPC = true;
      RestrictAddressFamilies = "AF_UNIX AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@clock ~@cpu-emulation ~@debug ~@module ~@mount ~@obsolete ~@privileged ~@raw-io ~@reboot ~@resources ~@swap";
    };
  };

  users.users.mega-sync = {
    isSystemUser = true;
    group = "data-members";
    extraGroups = [ "users" ];
  };

  modules.services.nginx.virtualHosts."mega.shiro.lan" = {
    ssl = true;

    locations."/" = {
      proxyPass = "http://unix:/run/mega-sync/mega-sync.socket";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      sso = true;
    };
  };
}
