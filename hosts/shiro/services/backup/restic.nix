{ config, lib, ... }:

with lib;
let
  backblaze = config.my.secrets.services.backblaze;
in
{
  services.restic.backups =
    let
      allBase = {
        initialize = true;
        paths = [
          "/var/lib/grafana"
          # "/zfs-main-pool/data/animu"
          "/zfs-main-pool/data/etc"
          "/zfs-main-pool/data/h"
          "/zfs-main-pool/data/jackett"
          "/zfs-main-pool/data/jellyfin"
          "/zfs-main-pool/data/qbittorrent"
          "/zfs-main-pool/data/sonarr"
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
        passwordFile = toString ./all-password;
        timerConfig = {
          OnCalendar = "daily";
        };
      };
    in
    {
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
            account = backblaze.backup.keyId;
            key = backblaze.backup.applicationKey;
            download_url = "https://6397f2b4ff373fe3.ggg.dev";
          };
        }
      ];
    };
}
