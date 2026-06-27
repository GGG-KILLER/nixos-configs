{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.restic.backups =
    let
      inherit (lib) mkMerge;
      base-settings = {
        initialize = false;
        repository = "rclone:b2:ggg-restic";
        environmentFile = config.age.secrets."backup.env".path;
        passwordFile = config.age.secrets."backup.key".path;
        rcloneConfig = {
          type = "b2";
          hard_delete = true;
        };
        extraBackupArgs = [
          "--compression max"
        ];
        timerConfig.Persistent = true;
      };
    in
    {
      # postgres = mkMerge [
      #   base-settings
      #   {
      #     extraBackupArgs = [ "--tag postgres" ];
      #     command = [
      #       "sudo"
      #       "-u"
      #       "postgres"
      #       "pg_dumpall"
      #       "--host=127.0.0.1"
      #       "--port=${toString config.jibril.ports.postgres}"
      #       "-w"
      #     ];
      #     timerConfig.OnCalendar = "18:00";
      #   }
      # ];
      filesystem = mkMerge [
        base-settings
        {
          progressFps = 5;
          paths = [
            "/home"
            "/opt"
            "/root"
            "/var"
          ];
          extraBackupArgs = [
            "--tag files"
            "--exclude-file=${pkgs.writeText "restic-excludes.txt" ''
              /home/*/.cache
              /root/.cache
              /var/tmp
              /var/cache
              /var/log
              /var/lib/grafana/data/log
            ''}"
          ];
          timerConfig.OnCalendar = "20:00";
        }
      ];
      prune = mkMerge [
        base-settings
        {
          progressFps = 5;
          pruneOpts = [
            "--group-by hosts,tags"
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 3"
          ];
          timerConfig.OnCalendar = "10:00";
        }
      ];
    };
}
