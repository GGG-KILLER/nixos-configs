{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe mkMerge;
in {
  services.restic.backups = let
    zfs = getExe pkgs.zfs;
    allBase = type: let
      baseDir = "/home/ggg/.zfs/snapshot/restic-backup-${type}";
    in {
      initialize = true;
      backupPrepareCommand = ''
        ${zfs} snapshot rpool/userdata/home/ggg@restic-backup-${type} && echo "[backupPrepareCommand] Snapshot created"
      '';
      backupCleanupCommand = ''
        ${zfs} destroy rpool/userdata/home/ggg@restic-backup-${type} && echo "[backupCleanupCommand] Snapshot deleted"
      '';
      paths = [
        baseDir
      ];
      extraBackupArgs = [
        "--compression max"
        "--exclude=${baseDir}/.android"
        "--exclude=${baseDir}/.cache"
        "--exclude=${baseDir}/.compose-cache"
        "--exclude=${baseDir}/.dotnet"
        "--exclude=${baseDir}/.java"
        "--exclude=${baseDir}/.nix-defexpr"
        "--exclude=${baseDir}/.nix-profile"
        "--exclude=${baseDir}/.nuget"
        "--exclude=${baseDir}/.nv"
        "--exclude=${baseDir}/.omnisharp"
        "--exclude=${baseDir}/.pki"
        "--exclude=${baseDir}/.templateengine"
        "--exclude=${baseDir}/.var/app/com.valvesoftware.Steam/.local/share/Steam"
        "--exclude=${baseDir}/.vscode"
        "--exclude=${baseDir}/Android"
        "--exclude=${baseDir}/Data"
        "--exclude=${baseDir}/Downloads"
        "--exclude=${baseDir}/Git"
        "--exclude=${baseDir}/Unity"
      ];
      pruneOpts = [
        "--group-by hosts"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
      passwordFile = config.age.secrets.backup-password.path;
      timerConfig = {
        OnCalendar = "daily";
      };
    };
  in {
    all-b2 = mkMerge [
      (allBase "b2")
      {
        repository = "rclone:b2:ggg-backups-sora";
        rcloneConfig = {
          type = "b2";
          hard_delete = true;
        };
        environmentFile = config.age.secrets.backup-envfile.path;
      }
    ];
  };
}
