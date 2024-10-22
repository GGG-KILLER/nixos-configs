{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkForce;
in
{
  services.restic.backups =
    let
      allBase =
        let
          baseDir = "/zfs-main-pool/data";
          excludeFile = pkgs.writeText "restic-excludes.txt" ''
            *.log
            *.pid
            /var/lib/grafana/data/log
            ${baseDir}/etc/Archives
            ${baseDir}/etc/glua-mc
            ${baseDir}/etc/ISOs
            ${baseDir}/etc/Leaks
            ${baseDir}/etc/phone
            ${baseDir}/etc/random
            ${baseDir}/etc/Reading Material/Gentoomen Library
            ${baseDir}/etc/School/FMU
            ${baseDir}/etc/Tools
            ${baseDir}/h
            !${baseDir}/h/Comics
            !${baseDir}/h/G
            !${baseDir}/h/Others
            !${baseDir}/h/Patreon
            ${baseDir}/home-assistant/.cache
            ${baseDir}/home-assistant/.esphome/build
            ${baseDir}/home-assistant/.platformio
            ${baseDir}/jackett/*.txt
            ${baseDir}/jackett/DataProtection
            ${baseDir}/jackett/Jackett/*.txt
            ${baseDir}/jackett/Jackett/DataProtection
            ${baseDir}/jellyfin/data/keyframes
            ${baseDir}/jellyfin/data/ScheduledTasks
            ${baseDir}/jellyfin/data/subtitles
            ${baseDir}/jellyfin/log
            ${baseDir}/jellyfin/metadata
            ${baseDir}/jellyfin/plugins/configurations/*/cache
            ${baseDir}/jellyfin/transcodes
            ${baseDir}/jellyfin/var-cache
            ${baseDir}/qbittorrent/qbittorrent/qBittorrent/data/GeoDB
            ${baseDir}/qbittorrent/qbittorrent/qBittorrent/data/logs
            ${baseDir}/series
            ${baseDir}/sonarr/asp
            ${baseDir}/sonarr/logs
            ${baseDir}/sonarr/MediaCover
            ${baseDir}/sonarr/Sentry
          '';
        in
        {
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
            "--exclude-file=${excludeFile}"
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
    in
    {
      all-local = mkMerge [
        allBase
        {
          repository = "/mnt/backup/all";
          pruneOpts = mkForce [
            "--group-by hosts"
            "--keep-daily 7"
          ];
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
