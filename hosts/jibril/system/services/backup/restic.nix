{ config, pkgs, ... }:
{
  services.restic.backups = {
    all-b2 = {
      initialize = true;
      repository = "rclone:b2:ggg-backups-shiro"; # TODO: Create bucket specifically for jibril
      rcloneConfig = {
        type = "b2";
        hard_delete = true;
      };
      environmentFile = config.age.secrets.backup-envfile.path;

      paths = [
        "/var/lib/grafana/data"
        "/var/lib/home-assistant/backups"
        "/var/lib/kanidm/backups"
        "/var/lib/pgsql-prd" # only prod is worth backing up
        "/var/lib/step-ca"
        "/var/lib/prometheus2"
      ];
      extraBackupArgs = [
        "--compression max"
        "--exclude-file=${pkgs.writeText "restic-excludes.txt" ''
          *.log
          *.pid
          /var/lib/grafana/data/log
        ''}"
      ];
      pruneOpts = [
        "--group-by hosts"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      passwordFile = config.age.secrets.backup-password.path;
      timerConfig = {
        OnCalendar = "daily";
      };
    };
  };
}
