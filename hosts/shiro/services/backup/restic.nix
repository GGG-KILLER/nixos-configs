{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge optionals optionalString;
in
{
  services.restic.backups =
    let
      allBase =
        let
          excludeFile = pkgs.writeText "restic-excludes.txt" ''
            *.log
            *.pid
            ${optionalString (!config.cost-saving.enable || !config.cost-saving.disable-hdds) ''
              /storage/etc/Archives
              /storage/etc/glua-mc
              /storage/etc/ISOs
              /storage/etc/Leaks
              /storage/etc/phone
              /storage/etc/random
              /storage/etc/Reading Material/Gentoomen Library
              /storage/etc/School/FMU
              /storage/etc/Tools
              /storage/h
              /storage/series
              !/storage/h/Comics
              !/storage/h/G
              !/storage/h/Others
              !/storage/h/Patreon
            ''}
            /var/lib/grafana/data/log
            /var/lib/home-assistant/.cache
            /var/lib/home-assistant/.esphome/build
            /var/lib/home-assistant/.platformio
            /var/lib/jackett/*.txt
            /var/lib/jackett/DataProtection
            /var/lib/jackett/Jackett/*.txt
            /var/lib/jackett/Jackett/DataProtection
            /var/lib/jellyfin/data/keyframes
            /var/lib/jellyfin/data/ScheduledTasks
            /var/lib/jellyfin/data/subtitles
            /var/lib/jellyfin/log
            /var/lib/jellyfin/metadata
            /var/lib/jellyfin/plugins/configurations/*/cache
            /var/lib/jellyfin/transcodes
            /var/lib/jellyfin/var-cache
            /var/lib/qbittorrent/qbittorrent/qBittorrent/data/GeoDB
            /var/lib/qbittorrent/qbittorrent/qBittorrent/data/logs
            /var/lib/sonarr/asp
            /var/lib/sonarr/logs
            /var/lib/sonarr/MediaCover
            /var/lib/sonarr/Sentry
          '';
        in
        {
          initialize = true;
          paths =
            [
              "/var/lib/grafana"
              "/var/lib/home-assistant"
              "/var/lib/jackett"
              "/var/lib/jellyfin"
              "/var/lib/pgsql-prd" # only prod is worth backing up
              "/var/lib/qbittorrent"
              "/var/lib/sonarr"
              "/var/lib/step-ca"
            ]
            ++ optionals (!config.cost-saving.enable) [
              "/storage/etc"
              "/storage/h"
              "/storage/series"
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
