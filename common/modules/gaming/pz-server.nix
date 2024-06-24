{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.pz-server;
in {
  options.modules.services.pz-server = {
    enable = mkEnableOption "enable the project zomboid server";
    serverDir = mkOption {
      type = types.str;
      description = "the path where server data will be stored at and the server binaries will be installed onto";
    };
    serverName = mkOption {
      type = types.str;
      description = "the name of the ini file to use when starting up the server";
    };
    adminUserName = mkOption {
      type = types.str;
      description = "the admin username";
    };
    adminPassword = mkOption {
      type = types.str;
      description = "the admin password";
    };
    user = mkOption {
      type = types.str;
      description = "the user the server should run as";
      default = "pzuser";
    };
    group = mkOption {
      type = types.str;
      description = "the group the server should run as";
      default = "pzuser";
    };
    openFirewall = mkOption {
      type = types.bool;
      description = "whether to open the required ports in the firewall for the server";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "pzuser") {
      ${cfg.user} = {
        group = cfg.group;
        home = cfg.serverDir;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "pzuser") {
      ${cfg.group} = {gid = null;};
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.serverDir}' 0755 ${cfg.user} ${cfg.group}"
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steamcmd"
        "steam-original"
      ];

    systemd.services.pz-server = let
      inherit (pkgs) stdenv libstdcxx5 zlib patchelf;
      inherit (pkgs.lib) makeLibraryPath;
      inherit (pkgs.steamPackages) steamcmd;
      steamcmdScript = pkgs.writeText "update_zomboid.txt" ''
        @ShutdownOnFailedCommand 1
        @NoPromptForPassword 1
        force_install_dir ${cfg.serverDir}
        login anonymous
        app_update 380870 validate
        quit
      '';
      libraryPath =
        "${stdenv.cc.cc.lib}/lib64:${cfg.serverDir}/linux64:${cfg.serverDir}/natives/lib:${cfg.serverDir}:${cfg.serverDir}/jre64/lib:"
        + makeLibraryPath [
          libstdcxx5 # libstdc++.so.6 libdl.so.2 libm.so.6 libgcc_s.so.1 libc.so.6 libpthread.so.0
          zlib # libz.so.1
        ];
    in {
      after = ["network.target"];
      description = "Project Zomboid Server";
      wantedBy = ["multi-user.target"];
      path = [
        steamcmd
        "${cfg.serverDir}/jre64"
      ];
      preStart = ''
        ${getExe' steamcmd "steamcmd"} +runscript ${steamcmdScript}
        ${getExe patchelf} \
          --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
          --set-rpath "${libraryPath}" \
          "${cfg.serverDir}/ProjectZomboid64" \
          "${cfg.serverDir}/jre64/bin/java"
      '';
      script = ''
        export PATH="${cfg.serverDir}/jre64/bin:$PATH"
        JSIG="libjsig.so"
        LD_PRELOAD="''${LD_PRELOAD}:''${JSIG}" ${cfg.serverDir}/ProjectZomboid64 \
          -servername "${cfg.serverName}" \
          -adminusername "${cfg.adminUserName}" \
          -adminpassword "${cfg.adminPassword}"
      '';
      environment = {
        LD_LIBRARY_PATH = libraryPath;
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        WorkingDirectory = cfg.serverDir;

        TimeoutStartSec = "900";
      };
    };
  };
}
