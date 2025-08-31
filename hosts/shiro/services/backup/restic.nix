{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.restic.backups.filesystem = {
    initialize = false;
    repository = "rclone:b2:ggg-restic";
    rcloneConfig = {
      type = "b2";
      hard_delete = true;
    };
    environmentFile = config.age.secrets."backup.env".path;
    passwordFile = config.age.secrets."backup.key".path;

    progressFps = 5;
    paths = [
      "/var/lib/jackett"
      "/var/lib/jellyfin"
      "/var/lib/qbittorrent"
      "/var/lib/sonarr"
    ]
    ++ lib.optionals (!config.cost-saving.enable) [
      "/storage/etc"
      "/storage/h"
      "/storage/series"
    ];
    extraBackupArgs = [
      "--compression max"
      "--tag files"
      "--exclude-file=${pkgs.writeText "restic-excludes.txt" ''
        *.log
        *.pid
        ${lib.optionalString (!config.cost-saving.enable || !config.cost-saving.disable-hdds) ''
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
      ''}"
    ];

    timerConfig = {
      Persistent = true;
      OnCalendar = "20:00";
    };
  };
}
