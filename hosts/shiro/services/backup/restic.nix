{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.my.secrets.services) backblaze;
in {
  services.restic.backups = let
    allBase = let
      baseDir = "/zfs-main-pool/data";
    in {
      initialize = true;
      paths = [
        "/var/lib/grafana"
        "${baseDir}/dbs/pgsql-prd" # only prod is worth backing up
        "${baseDir}/etc"
        "${baseDir}/h"
        "${baseDir}/home-assistant"
        "${baseDir}/jackett"
        "${baseDir}/jellyfin"
        "${baseDir}/qbittorrent"
        "${baseDir}/series"
        "${baseDir}/sonarr"
        "${baseDir}/step-ca"
      ];
      extraBackupArgs = [
        "--compression max"
        "--exclude=${baseDir}/etc/random"
        "--exclude=${baseDir}/etc/Archives"
        "--exclude=${baseDir}/h/G"
        "--exclude=${baseDir}/h/Playlists"
        "--exclude=${baseDir}/h/T"
        "--exclude=${baseDir}/home-assistant/.platformio"
        "--exclude=${baseDir}/jellyfin/metadata"
        "--exclude=${baseDir}/jellyfin/transcodes"
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
    all-local = mkMerge [
      allBase
      {
        repository = "/mnt/backup/all";
      }
    ];
    all-b2 = mkMerge [
      allBase
      {
        repository = "rclone:b2:ggg-backups-shiro";
        rcloneConfig = {
          type = "b2";
          hard_delete = true;
        };
        environmentFile = config.age.secrets.backup-envfile.path;
      }
    ];
  };
}
