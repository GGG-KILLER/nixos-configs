{ config, pkgs, ... }:
{
  services.restic.backups = {
    all-b2 = {
      repository = "rclone:b2:ggg-backups-shiro"; # TODO: Create bucket specifically for jibril
      rcloneConfig = {
        type = "b2";
        hard_delete = true;
      };
      environmentFile = config.age.secrets.backup-envfile.path;

      initialize = true;
      paths = [
        "/var/lib/grafana"
        "/var/lib/home-assistant"
        "/var/lib/kanidm"
        "/var/lib/pgsql-prd" # only prod is worth backing up
        "/var/lib/step-ca"
      ];
      extraBackupArgs = [
        "--compression max"
        "--exclude-file=${pkgs.writeText "restic-excludes.txt" ''
          *.log
          *.pid
          /var/lib/grafana/data/log
          /var/lib/home-assistant/.cache
          /var/lib/home-assistant/.esphome/build
          /var/lib/home-assistant/.platformio
        ''}"
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
  };
}
