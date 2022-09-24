{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.my.secrets.services) backblaze;
in {
  services.restic.backups = let
    allBase = {
      initialize = true;
      paths = [
        "/var/lib/grafana"
        "/zfs-main-pool/data/dbs/pgsql-prd" # only prod is worth backing up
        "/zfs-main-pool/data/etc"
        "/zfs-main-pool/data/h"
        "/zfs-main-pool/data/home-assistant"
        "/zfs-main-pool/data/jackett"
        "/zfs-main-pool/data/jellyfin"
        "/zfs-main-pool/data/qbittorrent"
        "/zfs-main-pool/data/series"
        "/zfs-main-pool/data/sonarr"
        "/zfs-main-pool/data/step-ca"
      ];
      extraBackupArgs = [
        "--exclude=/zfs-main-pool/data/h/G"
        "--exclude=/zfs-main-pool/data/etc/twitch-leaks-part-one"
        "--exclude=/zfs-main-pool/data/etc/mega-archive"
        ''--exclude="/zfs-main-pool/data/etc/April 22nd 2020, random leaked shit.rar"''
        "--exclude=/zfs-main-pool/data/etc/random"
        "--exclude=/zfs-main-pool/data/etc/CP2077"
        "--exclude=/zfs-main-pool/data/jellyfin/metadata"
      ];
      pruneOpts = [
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
        environmentFile = config.age.secrets.backup-password.path;
      }
    ];
  };
}
